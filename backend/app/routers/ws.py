"""WebSocket endpoint for real-time device state push.

Clients connect with a JWT query param, then send subscribe/unsubscribe messages
to register interest in specific devices. The server pushes state updates,
device events, and connectivity changes received from MQTT.
"""
import uuid
import json
import asyncio
import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, status
from app.services.auth_service import decode_token
from app.services.access_control import verify_device_access
from app.services.realtime_service import RealtimeService
from app.database import async_session_factory

logger = logging.getLogger(__name__)
router = APIRouter()


def _parse_uuids(raw: list) -> list[uuid.UUID]:
    result = []
    for item in raw:
        try:
            result.append(uuid.UUID(str(item)))
        except ValueError:
            pass
    return result


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    token = websocket.query_params.get("token")
    if not token:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    user_id = uuid.UUID(payload["sub"])
    realtime: RealtimeService = websocket.app.state.realtime

    await websocket.accept()
    queue = realtime.connect(user_id, websocket)

    async def writer():
        try:
            while True:
                msg = await queue.get()
                try:
                    await websocket.send_text(msg)
                except Exception:
                    break
        except asyncio.CancelledError:
            pass

    async def reader():
        while True:
            raw = await websocket.receive_text()
            try:
                msg = json.loads(raw)
            except json.JSONDecodeError:
                await queue.put(json.dumps({"type": "error", "message": "Invalid JSON"}))
                continue

            msg_type = msg.get("type")
            if msg_type == "subscribe":
                device_ids = await _resolve_device_ids(user_id, msg.get("device_ids", []))
                if not device_ids:
                    await queue.put(
                        json.dumps({"type": "error", "message": "No valid device_ids to subscribe"})
                    )
                    continue
                await realtime.subscribe(queue, device_ids)
                await queue.put(
                    json.dumps({"type": "subscribed", "device_ids": [str(d) for d in device_ids]})
                )
            elif msg_type == "unsubscribe":
                ids = _parse_uuids(msg.get("device_ids", []))
                if ids:
                    await realtime.unsubscribe(queue, ids)
                await queue.put(
                    json.dumps({"type": "unsubscribed", "device_ids": [str(d) for d in ids]})
                )
            else:
                await queue.put(
                    json.dumps({"type": "error", "message": f"Unknown message type: {msg_type}"})
                )

    reader_task = asyncio.create_task(reader())
    writer_task = asyncio.create_task(writer())

    try:
        done, pending = await asyncio.wait(
            [reader_task, writer_task],
            return_when=asyncio.FIRST_COMPLETED,
        )
        for task in pending:
            task.cancel()
    finally:
        realtime.disconnect(websocket)
        for task in [reader_task, writer_task]:
            if not task.done():
                task.cancel()
        await asyncio.gather(reader_task, writer_task, return_exceptions=True)


async def _resolve_device_ids(user_id: uuid.UUID, raw_ids: list) -> list[uuid.UUID]:
    parsed = _parse_uuids(raw_ids)
    if not parsed:
        return []
    valid = []
    async with async_session_factory() as db:
        for did in parsed:
            try:
                await verify_device_access(db, user_id, did, "view")
                valid.append(did)
            except PermissionError:
                pass
    return valid
