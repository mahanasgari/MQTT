"""Async MQTT client service using gmqtt.

Connects to the cloud MQTT broker, subscribes to device telemetry topics,
publishes commands, and persists state/events to the database.
"""
import uuid
import json
import logging
from collections.abc import Callable, Awaitable
from datetime import datetime, timezone
from gmqtt import Client as MQTTClient
from app.config import settings
from app.database import async_session_factory
from app.services.device_service import (
    handle_state_message,
    handle_event_message,
    handle_availability_message,
)

logger = logging.getLogger(__name__)

TOPIC_STATE = "tele/+/state"
TOPIC_EVENT = "tele/+/event"
TOPIC_AVAILABILITY = "tele/+/online"

StateChangeCallback = Callable[[uuid.UUID, str, dict], Awaitable[None]]


class MQTTService:
    """Manages the async MQTT connection and message routing."""

    def __init__(self):
        self._client = MQTTClient(settings.MQTT_CLIENT_ID)
        self._client.on_connect = self._on_connect
        self._client.on_message = self._on_message
        self._client.on_disconnect = self._on_disconnect
        self._disconnected = False
        self._state_change_callbacks: list[StateChangeCallback] = []
        self._connected = False

    @property
    def is_connected(self) -> bool:
        return self._connected and not self._disconnected

    async def start(self):
        logger.info(
            "Connecting to MQTT broker at %s:%s",
            settings.MQTT_BROKER_HOST,
            settings.MQTT_BROKER_PORT,
        )
        if settings.MQTT_USERNAME:
            self._client.set_auth_credentials(
                settings.MQTT_USERNAME, settings.MQTT_PASSWORD or ""
            )
        await self._client.connect(
            settings.MQTT_BROKER_HOST,
            settings.MQTT_BROKER_PORT,
            version=4,
        )

    async def stop(self):
        self._disconnected = True
        await self._client.disconnect()
        logger.info("MQTT client disconnected")

    def _on_connect(self, client, flags, rc, properties):
        self._connected = True
        logger.info("MQTT connected (rc=%s)", rc)
        client.subscribe(TOPIC_STATE, qos=1)
        client.subscribe(TOPIC_EVENT, qos=1)
        client.subscribe(TOPIC_AVAILABILITY, qos=1)
        logger.info(
            "Subscribed to %s, %s, %s", TOPIC_STATE, TOPIC_EVENT, TOPIC_AVAILABILITY
        )

    def _on_disconnect(self, client, packet, exc=None):
        self._connected = False
        if not self._disconnected:
            logger.warning("MQTT disconnected unexpectedly: %s", exc)

    async def _on_message(self, client, topic, payload, qos, properties):
        try:
            raw = payload.decode("utf-8")
            data = json.loads(raw)
        except (UnicodeDecodeError, json.JSONDecodeError) as e:
            logger.warning("Invalid MQTT payload on %s: %s", topic, e)
            return

        parts = topic.split("/")
        if len(parts) < 3:
            logger.warning("Unrecognized topic format: %s", topic)
            return

        serial = parts[1]
        suffix = parts[2]

        logger.debug("MQTT message topic=%s serial=%s suffix=%s", topic, serial, suffix)

        async with async_session_factory() as session:
            try:
                device_id: uuid.UUID | None = None
                if suffix == "state":
                    device_id = await handle_state_message(session, serial, data)
                elif suffix == "event":
                    device_id = await handle_event_message(session, serial, data)
                elif suffix == "online":
                    device_id = await handle_availability_message(session, serial, data)
                else:
                    logger.debug("Ignored topic suffix: %s", suffix)
                    return

                await session.commit()

                if device_id is not None:
                    await self._notify_state_change(device_id, suffix, data)

                logger.info("Processed %s from %s (%s)", suffix, serial, data.get("type", ""))
            except Exception as e:
                await session.rollback()
                logger.error("Failed to process MQTT message on %s: %s", topic, e)

    def on_state_change(self, callback: StateChangeCallback):
        self._state_change_callbacks.append(callback)

    def _get_suffix_map(self, suffix: str):
        return suffix

    async def _notify_state_change(self, device_id: uuid.UUID, suffix: str, data: dict):
        """Invoke all registered state-change callbacks."""
        for cb in self._state_change_callbacks:
            try:
                await cb(device_id, suffix, data)
            except Exception as e:
                logger.error("State change callback error: %s", e)

    async def publish_command(
        self, serial: str, command: str, value: str
    ) -> None:
        """Publish a control command to a device.

        Publishes to ``cmnd/{serial}/{command}`` with *value* as payload.
        Example: ``cmnd/SP123456789/power`` → ``on``
        """
        topic = f"cmnd/{serial}/{command}"
        logger.info("Publishing %s → %s", topic, value)
        self._client.publish(topic, value, qos=1)
