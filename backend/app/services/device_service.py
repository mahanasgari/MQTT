"""Business logic for device state and event persistence.
Called by MQTT callbacks and API routes.
"""
import uuid
import logging
from datetime import datetime, timezone
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.device import Device
from app.models.device_state import DeviceState
from app.models.device_event import DeviceEvent
from app.models.device_network_config import DeviceNetworkConfig

logger = logging.getLogger(__name__)


async def get_device_by_serial(db: AsyncSession, serial: str) -> Device | None:
    result = await db.execute(select(Device).where(Device.serial == serial))
    return result.scalar_one_or_none()


async def update_device_state(
    db: AsyncSession, device_id: uuid.UUID, data: dict
) -> DeviceState:
    state = await db.get(DeviceState, device_id)
    if state is None:
        state = DeviceState(device_id=device_id)
        db.add(state)

    if "power" in data and data["power"] in ("on", "off"):
        if state.power != data["power"]:
            state.power = data["power"]
            state.last_changed_at = datetime.now(timezone.utc)

    if "connectivity" in data and data["connectivity"] in ("online", "offline"):
        if state.connectivity != data["connectivity"]:
            state.connectivity = data["connectivity"]
            state.last_changed_at = datetime.now(timezone.utc)

    if "voltage" in data:
        state.voltage = float(data["voltage"])
    if "current" in data:
        state.current = float(data["current"])
    if "power_consumption" in data:
        state.power_consumption = float(data["power_consumption"])

    state.last_seen_at = datetime.now(timezone.utc)
    return state


async def create_device_event(
    db: AsyncSession,
    device_id: uuid.UUID,
    event_type: str,
    initiator: str = "device",
    initiator_id: uuid.UUID | None = None,
    payload: dict | None = None,
    occurred_at: datetime | None = None,
) -> DeviceEvent:
    event = DeviceEvent(
        device_id=device_id,
        type=event_type,
        initiator=initiator,
        initiator_id=initiator_id,
        payload=payload,
        occurred_at=occurred_at or datetime.now(timezone.utc),
    )
    db.add(event)
    return event


async def upsert_device_network(
    db: AsyncSession, device_id: uuid.UUID, data: dict
) -> DeviceNetworkConfig:
    result = await db.execute(
        select(DeviceNetworkConfig).where(DeviceNetworkConfig.device_id == device_id)
    )
    config = result.scalar_one_or_none()
    if config is None:
        config = DeviceNetworkConfig(device_id=device_id)
        db.add(config)

    if "ip" in data:
        config.ip_address = data["ip"]
    if "mac" in data:
        config.mac_address = data["mac"]
    if "wifi_ssid" in data:
        config.wifi_ssid = data["wifi_ssid"]
    if "rssi" in data:
        config.wifi_rssi = int(data["rssi"])
    if "firmware_version" in data:
        config.firmware_version = data["firmware_version"]

    config.last_seen_at = datetime.now(timezone.utc)
    return config


async def handle_state_message(db: AsyncSession, serial: str, data: dict) -> uuid.UUID | None:
    device = await get_device_by_serial(db, serial)
    if device is None:
        logger.warning("State from unknown device serial=%s", serial)
        return None

    existing = await db.get(DeviceState, device.id)
    prev_power = existing.power if existing else None

    state = await update_device_state(db, device.id, data)

    if prev_power is not None and state.power != prev_power:
        await create_device_event(
            db,
            device_id=device.id,
            event_type=f"power_{state.power}",
            initiator="device",
            payload={"previous": prev_power},
        )

    return device.id


async def handle_event_message(db: AsyncSession, serial: str, data: dict) -> uuid.UUID | None:
    device = await get_device_by_serial(db, serial)
    if device is None:
        logger.warning("Event from unknown device serial=%s", serial)
        return None

    event_type = data.get("type", "unknown")
    occurred_at_str = data.get("occurred_at")

    occurred_at = None
    if occurred_at_str:
        try:
            occurred_at = datetime.fromisoformat(occurred_at_str)
        except ValueError:
            occurred_at = datetime.now(timezone.utc)

    await create_device_event(
        db,
        device_id=device.id,
        event_type=event_type,
        initiator="device",
        payload={k: v for k, v in data.items() if k not in ("type", "occurred_at")},
        occurred_at=occurred_at,
    )

    if event_type in ("power_on", "power_off"):
        power_val = event_type.split("_")[1]
        await update_device_state(db, device.id, {"power": power_val})
    elif event_type == "device_online":
        await update_device_state(db, device.id, {"connectivity": "online"})
    elif event_type == "device_offline":
        await update_device_state(db, device.id, {"connectivity": "offline"})

    return device.id


async def handle_availability_message(db: AsyncSession, serial: str, data: dict) -> uuid.UUID | None:
    device = await get_device_by_serial(db, serial)
    if device is None:
        logger.warning("Availability from unknown device serial=%s", serial)
        return None

    status = data.get("status", "online")
    await update_device_state(db, device.id, {"connectivity": status})
    await upsert_device_network(db, device.id, data)

    await create_device_event(
        db,
        device_id=device.id,
        event_type=f"device_{status}",
        initiator="device",
        payload={k: v for k, v in data.items() if k != "status"},
    )

    return device.id
