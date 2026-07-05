import uuid
import secrets
import logging
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, func as sa_func
from sqlalchemy.ext.asyncio import AsyncSession
from app.dependencies import get_db, require_platform_admin
from app.models.user import User
from app.models.device import Device
from app.models.device_state import DeviceState
from app.models.device_event import DeviceEvent
from app.models.household import Household, HouseholdMember
from app.models.pairing_token import PairingToken
from app.config import settings
from app.schemas.admin import (
    AdminStatsResponse,
    AdminUserResponse,
    AdminUserListResponse,
    AdminDeviceListResponse,
    AdminHouseholdResponse,
    AdminHouseholdListResponse,
    AdminDeviceCreateRequest,
    AdminDeviceUpdateRequest,
    AdminPairingTokenRequest,
    AdminEventListResponse,
)
from app.schemas.device import DeviceResponse, DeviceStateResponse, PairingTokenResponse, DeviceEventResponse
from app.routers.devices import _device_to_response

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/stats", response_model=AdminStatsResponse)
async def admin_stats(
    db: AsyncSession = Depends(get_db),
    _admin: User = Depends(require_platform_admin),
):
    users = (await db.execute(
        select(sa_func.count(User.id)).where(User.deleted_at.is_(None))
    )).scalar() or 0
    households = (await db.execute(
        select(sa_func.count(Household.id)).where(Household.deleted_at.is_(None))
    )).scalar() or 0
    devices = (await db.execute(
        select(sa_func.count(Device.id)).where(Device.deleted_at.is_(None))
    )).scalar() or 0
    devices_linked = (await db.execute(
        select(sa_func.count(Device.id)).where(
            Device.deleted_at.is_(None),
            Device.household_id.isnot(None),
        )
    )).scalar() or 0
    devices_online = (await db.execute(
        select(sa_func.count(DeviceState.device_id)).where(DeviceState.connectivity == "online")
    )).scalar() or 0
    return AdminStatsResponse(
        users=users,
        households=households,
        devices=devices,
        devices_online=devices_online,
        devices_linked=devices_linked,
    )


@router.get("/users", response_model=AdminUserListResponse)
async def admin_list_users(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
    _admin: User = Depends(require_platform_admin),
):
    total = (await db.execute(
        select(sa_func.count(User.id)).where(User.deleted_at.is_(None))
    )).scalar() or 0
    result = await db.execute(
        select(User)
        .where(User.deleted_at.is_(None))
        .order_by(User.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    users = [
        AdminUserResponse(
            id=u.id,
            phone=u.phone,
            display_name=u.display_name,
            is_platform_admin=u.is_platform_admin,
            created_at=u.created_at,
        )
        for u in result.scalars().all()
    ]
    return AdminUserListResponse(users=users, total=total)


@router.get("/devices", response_model=AdminDeviceListResponse)
async def admin_list_devices(
    serial: str | None = None,
    household_id: uuid.UUID | None = None,
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
    _admin: User = Depends(require_platform_admin),
):
    q = select(Device).where(Device.deleted_at.is_(None))
    if serial:
        q = q.where(Device.serial.ilike(f"%{serial}%"))
    if household_id:
        q = q.where(Device.household_id == household_id)

    total = (await db.execute(select(sa_func.count()).select_from(q.subquery()))).scalar() or 0
    result = await db.execute(q.order_by(Device.created_at.desc()).limit(limit).offset(offset))
    devices = [await _device_to_response(d) for d in result.scalars().all()]
    return AdminDeviceListResponse(devices=devices, total=total)


@router.post("/devices", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
async def admin_create_device(
    body: AdminDeviceCreateRequest,
    db: AsyncSession = Depends(get_db),
    _admin: User = Depends(require_platform_admin),
):
    serial = body.serial.strip().upper()
    existing = await db.execute(select(Device).where(Device.serial == serial))
    if existing.scalar_one_or_none() is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Serial already exists")

    device = Device(
        serial=serial,
        name=body.name,
        model=body.model,
        mac=body.mac,
        device_type="smart_plug",
    )
    db.add(device)
    await db.flush()
    db.add(DeviceState(device_id=device.id))
    await db.commit()
    await db.refresh(device)
    return await _device_to_response(device)


@router.patch("/devices/{device_id}", response_model=DeviceResponse)
async def admin_update_device(
    device_id: uuid.UUID,
    body: AdminDeviceUpdateRequest,
    db: AsyncSession = Depends(get_db),
    _admin: User = Depends(require_platform_admin),
):
    device = await db.get(Device, device_id)
    if device is None or device.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    if body.soft_delete:
        device.deleted_at = datetime.now(timezone.utc)
    if body.name is not None:
        device.name = body.name
    if body.unlink:
        device.household_id = None
        device.linked_at = None
    elif body.household_id is not None:
        h = await db.get(Household, body.household_id)
        if h is None or h.deleted_at is not None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Household not found")
        device.household_id = body.household_id
        device.linked_at = datetime.now(timezone.utc)

    await db.commit()
    await db.refresh(device)
    return await _device_to_response(device)


@router.get("/households", response_model=AdminHouseholdListResponse)
async def admin_list_households(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
    _admin: User = Depends(require_platform_admin),
):
    total = (await db.execute(
        select(sa_func.count(Household.id)).where(Household.deleted_at.is_(None))
    )).scalar() or 0
    result = await db.execute(
        select(Household)
        .where(Household.deleted_at.is_(None))
        .order_by(Household.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    households = []
    for h in result.scalars().all():
        member_count = (await db.execute(
            select(sa_func.count(HouseholdMember.id)).where(HouseholdMember.household_id == h.id)
        )).scalar() or 0
        device_count = (await db.execute(
            select(sa_func.count(Device.id)).where(
                Device.household_id == h.id,
                Device.deleted_at.is_(None),
            )
        )).scalar() or 0
        households.append(
            AdminHouseholdResponse(
                id=h.id,
                name=h.name,
                timezone=h.timezone,
                member_count=member_count,
                device_count=device_count,
                created_at=h.created_at,
            )
        )
    return AdminHouseholdListResponse(households=households, total=total)


@router.post("/pairing-token", response_model=PairingTokenResponse, status_code=status.HTTP_201_CREATED)
async def admin_create_pairing_token(
    body: AdminPairingTokenRequest,
    db: AsyncSession = Depends(get_db),
    _admin: User = Depends(require_platform_admin),
):
    payload: dict[str, str] = {}
    if body.household_id is not None:
        payload["household_id"] = str(body.household_id)
    if body.serial is not None:
        payload["serial"] = body.serial.upper()

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


@router.get("/events", response_model=AdminEventListResponse)
async def admin_list_events(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
    _admin: User = Depends(require_platform_admin),
):
    total = (await db.execute(select(sa_func.count(DeviceEvent.id)))).scalar() or 0
    result = await db.execute(
        select(DeviceEvent)
        .order_by(DeviceEvent.occurred_at.desc())
        .limit(limit)
        .offset(offset)
    )
    events = [
        DeviceEventResponse(
            id=e.id,
            device_id=e.device_id,
            type=e.type,
            initiator=e.initiator,
            initiator_id=e.initiator_id,
            metadata=e.payload,
            occurred_at=e.occurred_at,
        )
        for e in result.scalars().all()
    ]
    return AdminEventListResponse(events=events, total=total)
