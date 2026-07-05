import uuid
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.dependencies import get_db, get_current_user
from app.models.user import User
from app.models.household import Household, HouseholdMember
from app.schemas.household import (
    HouseholdCreate,
    HouseholdUpdate,
    HouseholdResponse,
    HouseholdListResponse,
)
from app.services.access_control import verify_household_role, list_user_households

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("", response_model=HouseholdListResponse)
async def list_households(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = await list_user_households(db, user.id)
    households = [
        HouseholdResponse(
            id=r["household"].id,
            name=r["household"].name,
            timezone=r["household"].timezone,
            role=r["role"],
            device_count=r["device_count"],
            created_at=r["household"].created_at,
        )
        for r in rows
    ]
    return HouseholdListResponse(households=households)


@router.post("", response_model=HouseholdResponse, status_code=status.HTTP_201_CREATED)
async def create_household(
    body: HouseholdCreate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    household = Household(name=body.name, timezone=body.timezone)
    db.add(household)
    await db.flush()

    member = HouseholdMember(household_id=household.id, user_id=user.id, role="admin")
    db.add(member)
    await db.commit()
    await db.refresh(household)

    return HouseholdResponse(
        id=household.id,
        name=household.name,
        timezone=household.timezone,
        role="admin",
        device_count=0,
        created_at=household.created_at,
    )


@router.get("/{household_id}", response_model=HouseholdResponse)
async def get_household(
    household_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    household = await db.get(Household, household_id)
    if household is None or household.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Household not found")

    try:
        role = await verify_household_role(db, user.id, household_id, "member")
    except PermissionError:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not a member of this household")

    from sqlalchemy import select, func as sa_func
    from app.models.device import Device
    cnt = await db.execute(
        select(sa_func.count(Device.id)).where(
            Device.household_id == household_id, Device.deleted_at.is_(None)
        )
    )
    device_count = cnt.scalar() or 0

    return HouseholdResponse(
        id=household.id,
        name=household.name,
        timezone=household.timezone,
        role=role,
        device_count=device_count,
        created_at=household.created_at,
    )


@router.patch("/{household_id}")
async def update_household(
    household_id: uuid.UUID,
    body: HouseholdUpdate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    household = await db.get(Household, household_id)
    if household is None or household.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Household not found")

    try:
        await verify_household_role(db, user.id, household_id, "admin")
    except PermissionError:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin role required")

    if body.name is not None:
        household.name = body.name
    if body.timezone is not None:
        household.timezone = body.timezone
    await db.commit()
    return {"status": "updated"}


@router.delete("/{household_id}")
async def delete_household(
    household_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    household = await db.get(Household, household_id)
    if household is None or household.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Household not found")

    try:
        await verify_household_role(db, user.id, household_id, "admin")
    except PermissionError:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin role required")

    from sqlalchemy import select, func as sa_func
    from app.models.device import Device
    cnt = await db.execute(
        select(sa_func.count(Device.id)).where(
            Device.household_id == household_id, Device.deleted_at.is_(None)
        )
    )
    if (cnt.scalar() or 0) > 0:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Cannot delete household with linked devices. Unlink devices first.",
        )

    from datetime import datetime, timezone
    household.deleted_at = datetime.now(timezone.utc)
    await db.commit()
    return {"status": "deleted"}
