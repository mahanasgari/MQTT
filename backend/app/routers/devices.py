import uuid
import secrets
import logging
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, Request, HTTPException, status, Query
from sqlalchemy import select, func as sa_func
from sqlalchemy.ext.asyncio import AsyncSession
from app.dependencies import get_db, get_current_user, require_device_permission
from app.models.user import User
from app.models.device import Device
from app.models.device_state import DeviceState
from app.models.device_event import DeviceEvent
from app.models.pairing_token import PairingToken
from app.models.share_permission import SharePermission
from app.schemas.device import (
    DeviceListResponse,
    DeviceResponse,
    DeviceStateResponse,
    DeviceFullStateResponse,
    DeviceUpdate,
    DeviceLinkRequest,
    DeviceControlRequest,
    DeviceSimulateRequest,
    LocalTestDeviceRequest,
    DeviceRegisterRequest,
    ProvisionPairingTokenRequest,
    PairingTokenCreateRequest,
    PairingTokenResponse,
    DeviceEventResponse as DeviceEventRespSchema,
    DeviceEventListResponse,
)
from app.schemas.share import SharedUserResponse, SharedUserListResponse
from app.config import settings
from app.models.household import Household, HouseholdMember
from app.services.access_control import list_accessible_device_ids, verify_household_role, list_user_households
from app.services.device_service import create_device_event, apply_local_telemetry

logger = logging.getLogger(__name__)
router = APIRouter()


async def _device_to_response(device: Device) -> DeviceResponse:
    state = None
    if device.state:
        state = DeviceStateResponse(
            power=device.state.power,
            connectivity=device.state.connectivity,
            last_changed_at=device.state.last_changed_at,
            last_seen_at=device.state.last_seen_at,
        )
    return DeviceResponse(
        id=device.id,
        serial=device.serial,
        name=device.name,
        household_id=device.household_id,
        firmware_version=device.firmware_version,
        state=state,
        created_at=device.created_at,
    )


@router.get("", response_model=DeviceListResponse)
async def list_devices(
    household_id: str | None = None,
    linked: bool | None = None,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    ids = await list_accessible_device_ids(db, user.id)
    if not ids:
        return DeviceListResponse(devices=[])

    result = await db.execute(
        select(Device).where(Device.id.in_(ids), Device.deleted_at.is_(None))
    )
    devices = result.scalars().all()

    if household_id:
        hid = uuid.UUID(household_id)
        devices = [d for d in devices if d.household_id == hid]
    if linked is True:
        devices = [d for d in devices if d.household_id is not None]
    elif linked is False:
        devices = [d for d in devices if d.household_id is None]

    items = [await _device_to_response(d) for d in devices]
    return DeviceListResponse(devices=items)


@router.post("/register", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
async def register_device(
    body: DeviceRegisterRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(PairingToken).where(
            PairingToken.token == body.token,
            PairingToken.status == "pending",
        )
    )
    token = result.scalar_one_or_none()
    if token is None or token.expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired pairing token")

    if token.payload and token.payload.get("serial"):
        if token.payload["serial"].upper() != body.serial.upper():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Serial number does not match pairing token",
            )

    household_id = None
    if token.payload and "household_id" in token.payload:
        try:
            household_id = uuid.UUID(token.payload["household_id"])
        except (ValueError, TypeError):
            pass

    from app.models.household import Household
    if household_id:
        h = await db.get(Household, household_id)
        if h is None or h.deleted_at is not None:
            household_id = None
        else:
            try:
                await verify_household_role(db, user.id, household_id, "admin")
            except PermissionError as e:
                raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))

    existing = await db.execute(select(Device).where(Device.serial == body.serial))
    device = existing.scalar_one_or_none()

    if settings.REQUIRE_PREREGISTERED_SERIAL and device is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Unknown serial number — device must be registered at factory",
        )

    is_new_device = False
    if device is not None:
        if device.deleted_at is not None:
            device.deleted_at = None
            device.household_id = household_id
            device.name = body.name
        elif device.household_id is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Device already registered to a household")
        else:
            device.household_id = household_id
            device.name = body.name or device.name
    else:
        is_new_device = True
        device = Device(
            serial=body.serial,
            name=body.name,
            household_id=household_id,
        )
        db.add(device)
        await db.flush()

    if is_new_device or await db.get(DeviceState, device.id) is None:
        db.add(DeviceState(device_id=device.id))

    if household_id and device.linked_at is None:
        device.linked_at = datetime.now(timezone.utc)

    token.status = "used"
    token.used_at = datetime.now(timezone.utc)
    token.device_id = device.id

    await create_device_event(db, device.id, "provisioned", initiator="user", initiator_id=user.id)
    await db.commit()
    await db.refresh(device)
    return await _device_to_response(device)


@router.post("/pairing-token", response_model=PairingTokenResponse, status_code=status.HTTP_201_CREATED)
async def create_provisioning_pairing_token(
    body: ProvisionPairingTokenRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    payload: dict[str, str] = {}
    if body.household_id is not None:
        try:
            await verify_household_role(db, user.id, body.household_id, "admin")
        except PermissionError as e:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))
        payload["household_id"] = str(body.household_id)
    if body.serial is not None:
        payload["serial"] = body.serial.upper()

    if settings.REQUIRE_PREREGISTERED_SERIAL and body.serial:
        result = await db.execute(
            select(Device).where(Device.serial == body.serial.upper(), Device.deleted_at.is_(None))
        )
        if result.scalar_one_or_none() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Unknown serial number — device must be registered at factory",
            )

    token_str = secrets.token_urlsafe(48)
    pt = PairingToken(
        device_id=None,
        token=token_str,
        status="pending",
        expires_at=datetime.now(timezone.utc)
        + timedelta(hours=settings.PAIRING_TOKEN_PROVISION_TTL_HOURS),
        payload=payload or None,
    )
    db.add(pt)
    await db.commit()
    await db.refresh(pt)
    return PairingTokenResponse(
        id=pt.id,
        token=pt.token,
        status=pt.status,
        expires_at=pt.expires_at,
    )


async def _broadcast_state(request: Request, device_id: uuid.UUID, data: dict) -> None:
    realtime = getattr(request.app.state, "realtime", None)
    if realtime is None:
        return
    if "power" in data or "connectivity" in data:
        await realtime.broadcast(device_id, "state_update", data)
    if "connectivity" in data:
        await realtime.broadcast(
            device_id, "connectivity_change", {"connectivity": data["connectivity"]}
        )


@router.post("/local-test", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
async def create_local_test_device(
    request: Request,
    body: LocalTestDeviceRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """One-click virtual plug for local testing (no hardware required)."""
    household_id = body.household_id
    if household_id is None:
        rows = await list_user_households(db, user.id)
        if rows:
            household_id = rows[0]["household"].id
        else:
            household = Household(name="خانه محلی", timezone="Asia/Tehran")
            db.add(household)
            await db.flush()
            db.add(HouseholdMember(household_id=household.id, user_id=user.id, role="admin"))
            household_id = household.id
    else:
        try:
            await verify_household_role(db, user.id, household_id, "member")
        except PermissionError as e:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))

    serial = f"LOCAL-{secrets.token_hex(4).upper()}"
    device = Device(
        serial=serial,
        name=body.name or "پریز آزمایشی",
        household_id=household_id,
        firmware_version="virtual",
        linked_at=datetime.now(timezone.utc),
    )
    db.add(device)
    await db.flush()
    db.add(DeviceState(device_id=device.id, power="off", connectivity="online"))
    await create_device_event(db, device.id, "provisioned", initiator="user", initiator_id=user.id)
    await create_device_event(db, device.id, "linked", initiator="user", initiator_id=user.id)
    data = await apply_local_telemetry(
        db, device, power="off", connectivity="online", initiator="user", initiator_id=user.id
    )
    await db.commit()
    await db.refresh(device)

    mqtt = getattr(request.app.state, "mqtt", None)
    if mqtt is not None:
        mqtt.publish_device_telemetry(device.serial, power="off", connectivity="online")
    await _broadcast_state(request, device.id, data or {"power": "off", "connectivity": "online"})
    return await _device_to_response(device)


# --- Routes with {device_id} path parameter ---
# These must come after /register, /pairing-token, and /local-test to avoid path conflicts


@router.get("/{device_id}", response_model=DeviceResponse)
async def get_device(
    device: Device = Depends(require_device_permission("view")),
):
    return await _device_to_response(device)


@router.get("/{device_id}/state", response_model=DeviceFullStateResponse)
async def get_device_state(
    device: Device = Depends(require_device_permission("view")),
    db: AsyncSession = Depends(get_db),
):
    state = await db.get(DeviceState, device.id)
    if state is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device state not available")
    return DeviceFullStateResponse(
        power=state.power,
        connectivity=state.connectivity,
        voltage=state.voltage,
        current=state.current,
        power_consumption=state.power_consumption,
        last_changed_at=state.last_changed_at,
        last_seen_at=state.last_seen_at,
    )


@router.get("/{device_id}/events", response_model=DeviceEventListResponse)
async def list_device_events(
    device: Device = Depends(require_device_permission("view")),
    db: AsyncSession = Depends(get_db),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    from_: str | None = Query(None, alias="from"),
    to: str | None = Query(None),
):
    conditions = [DeviceEvent.device_id == device.id]
    if from_:
        try:
            conditions.append(DeviceEvent.occurred_at >= datetime.fromisoformat(from_))
        except ValueError:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid 'from' date format")
    if to:
        try:
            conditions.append(DeviceEvent.occurred_at <= datetime.fromisoformat(to))
        except ValueError:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid 'to' date format")

    total_q = await db.execute(
        select(sa_func.count(DeviceEvent.id)).where(*conditions)
    )
    total = total_q.scalar() or 0

    result = await db.execute(
        select(DeviceEvent)
        .where(*conditions)
        .order_by(DeviceEvent.occurred_at.desc())
        .offset(offset)
        .limit(limit)
    )
    events = result.scalars().all()

    items = [
        DeviceEventRespSchema(
            id=e.id,
            device_id=e.device_id,
            type=e.type,
            initiator=e.initiator,
            initiator_id=e.initiator_id,
            metadata=e.payload,
            occurred_at=e.occurred_at,
        )
        for e in events
    ]
    return DeviceEventListResponse(events=items, total=total)


@router.get("/{device_id}/shares", response_model=SharedUserListResponse)
async def list_device_shares(
    device: Device = Depends(require_device_permission("admin")),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(SharePermission)
        .where(
            SharePermission.scope == "device",
            SharePermission.scope_id == device.id,
            SharePermission.deleted_at.is_(None),
        )
        .order_by(SharePermission.created_at.desc())
    )
    shares = result.scalars().all()

    items = [
        SharedUserResponse(
            id=s.id,
            grantee_phone=s.grantee_phone,
            permission=s.permission,
            status=s.status,
            created_at=s.created_at,
        )
        for s in shares
    ]
    return SharedUserListResponse(shares=items)


@router.patch("/{device_id}")
async def update_device(
    body: DeviceUpdate,
    device: Device = Depends(require_device_permission("admin")),
    db: AsyncSession = Depends(get_db),
):
    if body.name is not None:
        device.name = body.name
    await db.commit()
    return {"status": "updated"}


@router.patch("/{device_id}/link")
async def link_device(
    device_id: uuid.UUID,
    body: DeviceLinkRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    try:
        await verify_household_role(db, user.id, body.household_id, "member")
    except PermissionError as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))

    device = await db.get(Device, device_id)
    if device is None or device.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    if device.household_id is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Device already linked")

    prov = await db.execute(
        select(DeviceEvent).where(
            DeviceEvent.device_id == device_id,
            DeviceEvent.type == "provisioned",
            DeviceEvent.initiator_id == user.id,
        ).limit(1)
    )
    if prov.scalar_one_or_none() is None:
        accessible = await list_accessible_device_ids(db, user.id)
        if device_id not in accessible:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to link this device",
            )

    device.household_id = body.household_id
    if body.name is not None:
        device.name = body.name
    device.linked_at = datetime.now(timezone.utc)
    await create_device_event(db, device.id, "linked", initiator="user", initiator_id=user.id)
    await db.commit()
    return {"status": "linked"}


@router.patch("/{device_id}/control")
async def control_device(
    body: DeviceControlRequest,
    request: Request,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
    device: Device = Depends(require_device_permission("control")),
):
    if device.household_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Device not linked to a household"
        )
    if body.command != "power" or body.value not in ("on", "off"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Only power on/off is supported"
        )

    mqtt = getattr(request.app.state, "mqtt", None)
    mqtt_ok = False
    if mqtt is not None and mqtt.is_connected:
        try:
            await mqtt.publish_command(device.serial, body.command, body.value)
            mqtt_ok = True
        except Exception as e:
            logger.error("Failed to publish MQTT command to %s: %s", device.serial, e)

    is_virtual = (device.firmware_version or "").lower() == "virtual"
    if is_virtual or not mqtt_ok:
        data = await apply_local_telemetry(
            db,
            device,
            power=body.value,
            connectivity="online",
            initiator="user",
            initiator_id=user.id,
        )
        await db.commit()
        if mqtt is not None:
            mqtt.publish_device_telemetry(
                device.serial, power=body.value, connectivity="online"
            )
        await _broadcast_state(request, device.id, data)
        if not mqtt_ok and not is_virtual:
            logger.warning("MQTT unavailable — applied local state for %s", device.serial)
        return {"status": "accepted"}

    if not mqtt_ok:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY, detail="MQTT publish failed"
        )
    return {"status": "accepted"}


@router.post("/{device_id}/simulate", response_model=DeviceResponse)
async def simulate_device(
    body: DeviceSimulateRequest,
    request: Request,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
    device: Device = Depends(require_device_permission("control")),
):
    """Bring a device online/offline locally (virtual plug or MQTT echo)."""
    power = body.power if body.power in ("on", "off") else None
    connectivity = body.connectivity if body.connectivity in ("online", "offline") else "online"
    if power is None:
        state = await db.get(DeviceState, device.id)
        power = state.power if state else "off"

    data = await apply_local_telemetry(
        db,
        device,
        power=power,
        connectivity=connectivity,
        initiator="user",
        initiator_id=user.id,
    )
    await db.commit()
    await db.refresh(device)

    mqtt = getattr(request.app.state, "mqtt", None)
    if mqtt is not None:
        mqtt.publish_device_telemetry(device.serial, power=power, connectivity=connectivity)
    await _broadcast_state(request, device.id, data)
    return await _device_to_response(device)


@router.post("/{device_id}/pairing-token", response_model=PairingTokenResponse)
async def create_device_pairing_token(
    body: PairingTokenCreateRequest,
    device: Device = Depends(require_device_permission("admin")),
    db: AsyncSession = Depends(get_db),
):
    token_str = secrets.token_urlsafe(48)
    pt = PairingToken(
        device_id=device.id,
        token=token_str,
        status="pending",
        expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
        payload={"household_id": str(device.household_id)} if device.household_id and not body.household_id
        else ({"household_id": str(body.household_id)} if body.household_id else None),
    )
    db.add(pt)
    await db.commit()
    await db.refresh(pt)
    return PairingTokenResponse(
        id=pt.id,
        token=pt.token,
        status=pt.status,
        expires_at=pt.expires_at,
    )


@router.delete("/{device_id}")
async def delete_device(
    db: AsyncSession = Depends(get_db),
    device: Device = Depends(require_device_permission("admin")),
):
    device.deleted_at = datetime.now(timezone.utc)
    await db.commit()
    return {"status": "deleted"}
