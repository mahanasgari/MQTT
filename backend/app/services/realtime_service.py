"""In-memory WebSocket connection and subscription manager.

Tracks authenticated WebSocket connections per user and per-device subscriptions
so that MQTT-driven state changes can be pushed to the right clients.
"""
import asyncio
import uuid
import json
import logging
from fastapi import WebSocket

logger = logging.getLogger(__name__)


class RealtimeService:
    """Manages WebSocket connections and device-subscription mappings.

    Each connection gets an asyncio.Queue; ws.py writer task drains the queue.
    MQTT broadcast enqueues messages to avoid concurrent send_text races.
    """

    def __init__(self):
        self._connections: dict[uuid.UUID, list[WebSocket]] = {}
        self._queue_to_ws: dict[int, WebSocket] = {}
        self._ws_to_queue: dict[int, asyncio.Queue] = {}
        self._subs_by_queue: dict[int, set[uuid.UUID]] = {}
        self._subs_by_device: dict[uuid.UUID, set[int]] = {}

    def connect(self, user_id: uuid.UUID, websocket: WebSocket) -> asyncio.Queue:
        queue: asyncio.Queue = asyncio.Queue()
        qid = id(queue)
        ws_id = id(websocket)

        if user_id not in self._connections:
            self._connections[user_id] = []
        self._connections[user_id].append(websocket)

        self._queue_to_ws[qid] = websocket
        self._ws_to_queue[ws_id] = queue
        self._subs_by_queue[qid] = set()

        logger.debug("WS connected user=%s total=%d", user_id, len(self._connections[user_id]))
        return queue

    def disconnect(self, websocket: WebSocket):
        ws_id = id(websocket)
        queue = self._ws_to_queue.pop(ws_id, None)
        if queue is not None:
            qid = id(queue)
            subscribed = self._subs_by_queue.pop(qid, set())
            for dev_id in subscribed:
                per_device = self._subs_by_device.get(dev_id)
                if per_device:
                    per_device.discard(qid)
                    if not per_device:
                        del self._subs_by_device[dev_id]
            self._queue_to_ws.pop(qid, None)

        for uid, conns in list(self._connections.items()):
            if websocket in conns:
                conns.remove(websocket)
                if not conns:
                    del self._connections[uid]
                break

        logger.debug("WS disconnected ws_id=%d", ws_id)

    async def subscribe(self, queue: asyncio.Queue, device_ids: list[uuid.UUID]):
        qid = id(queue)
        user_devices = self._subs_by_queue.setdefault(qid, set())

        for did in device_ids:
            if did not in user_devices:
                user_devices.add(did)
                self._subs_by_device.setdefault(did, set()).add(qid)

    async def unsubscribe(self, queue: asyncio.Queue, device_ids: list[uuid.UUID]):
        qid = id(queue)
        user_devices = self._subs_by_queue.get(qid, set())

        for did in device_ids:
            user_devices.discard(did)
            per_device = self._subs_by_device.get(did)
            if per_device:
                per_device.discard(qid)
                if not per_device:
                    del self._subs_by_device[did]

    async def broadcast(self, device_id: uuid.UUID, change_type: str, data: dict):
        """Enqueue *data* for every connection subscribed to *device_id*."""
        payload = json.dumps({
            "type": change_type,
            "device_id": str(device_id),
            "data": data,
        })
        queue_ids = self._subs_by_device.get(device_id, set())
        if not queue_ids:
            return

        stale: set[int] = set()
        for qid in queue_ids:
            ws = self._queue_to_ws.get(qid)
            queue = self._ws_to_queue.get(id(ws)) if ws else None
            if ws is None or queue is None:
                stale.add(qid)
                continue
            try:
                await queue.put(payload)
            except Exception as e:
                logger.warning("WS queue error device=%s: %s", device_id, e)
                stale.add(qid)

        for qid in stale:
            ws = self._queue_to_ws.get(qid)
            if ws is not None:
                self.disconnect(ws)
