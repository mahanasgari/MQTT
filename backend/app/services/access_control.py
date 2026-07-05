import uuid
import logging
from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.models.user import User
from app.models.device import Device
from app.models.household import Household, HouseholdMember
from app.models.share_permission import SharePermission

logger = logging.getLogger(__name__)

PERMISSION_ORDER = {"view": 0, "control": 1, "admin": 2}
ROLE_ORDER = {"member": 1, "admin": 2}


def _sufficient(current: str | None, required: str) -> bool:
    if current is None:
        return False
    return PERMISSION_ORDER.get(current, -1) >= PERMISSION_ORDER.get(required, 999)


async def get_household_role(db: AsyncSession, user_id: uuid.UUID, household_id: uuid.UUID) -> str | None:
    result = await db.execute(
        select(HouseholdMember.role).where(
            HouseholdMember.household_id == household_id,
            HouseholdMember.user_id == user_id,
        )
    )
    return result.scalar_one_or_none()


async def get_device_shares(
    db: AsyncSession, user_id: uuid.UUID, device: Device
) -> list[str]:
    results = await db.execute(
        select(SharePermission.permission).where(
            SharePermission.grantee_user_id == user_id,
            SharePermission.deleted_at.is_(None),
            SharePermission.status == "accepted",
            or_(
                SharePermission.scope == "device",
                SharePermission.scope_id == device.id,
                SharePermission.scope == "household",
                SharePermission.scope_id == device.household_id,
            ),
        )
    )
    return list(results.scalars().all())


async def get_effective_permission(
    db: AsyncSession, user_id: uuid.UUID, device_id: uuid.UUID
) -> str | None:
    device = await db.get(Device, device_id)
    if device is None or device.deleted_at is not None:
        return None

    best: int = -1
    best_label: str | None = None

    if device.household_id is not None:
        role = await get_household_role(db, user_id, device.household_id)
        if role is not None:
            level = ROLE_ORDER.get(role, 0)
            if level > best:
                best = level
                best_label = "admin" if role == "admin" else "control"

    share_perms = await get_device_shares(db, user_id, device)
    for sp in share_perms:
        level = PERMISSION_ORDER.get(sp, -1)
        if level > best:
            best = level
            best_label = sp

    return best_label


async def verify_device_access(
    db: AsyncSession, user_id: uuid.UUID, device_id: uuid.UUID, required: str
) -> Device:
    device = await db.get(Device, device_id)
    if device is None or device.deleted_at is not None:
        raise PermissionError("Device not found")

    permission = await get_effective_permission(db, user_id, device_id)
    if not _sufficient(permission, required):
        raise PermissionError(
            f"Requires '{required}' permission, user has '{permission or 'none'}'"
        )
    return device


async def verify_household_role(
    db: AsyncSession, user_id: uuid.UUID, household_id: uuid.UUID, required_role: str
) -> str:
    role = await get_household_role(db, user_id, household_id)
    if role is None:
        raise PermissionError("User is not a member of this household")
    required_level = ROLE_ORDER.get(required_role, 0)
    actual_level = ROLE_ORDER.get(role, 0)
    if actual_level < required_level:
        raise PermissionError(f"Requires role '{required_role}' in household, user has '{role}'")
    return role


async def list_user_households(db: AsyncSession, user_id: uuid.UUID) -> list[dict]:
    result = await db.execute(
        select(HouseholdMember).where(HouseholdMember.user_id == user_id)
    )
    memberships = result.scalars().all()

    households = []
    for m in memberships:
        household = await db.get(Household, m.household_id)
        if household is None or household.deleted_at is not None:
            continue
        from app.models.device import Device
        from sqlalchemy import func as sa_func
        count_result = await db.execute(
            select(sa_func.count(Device.id)).where(
                Device.household_id == household.id,
                Device.deleted_at.is_(None),
            )
        )
        device_count = count_result.scalar() or 0
        households.append({
            "household": household,
            "role": m.role,
            "device_count": device_count,
        })
    return households


async def list_accessible_device_ids(db: AsyncSession, user_id: uuid.UUID) -> list[uuid.UUID]:
    household_subq = (
        select(HouseholdMember.household_id)
        .where(HouseholdMember.user_id == user_id)
        .subquery()
    )

    share_device_subq = (
        select(SharePermission.scope_id)
        .where(
            SharePermission.grantee_user_id == user_id,
            SharePermission.deleted_at.is_(None),
            SharePermission.status == "accepted",
            SharePermission.scope == "device",
        )
        .subquery()
    )

    share_household_subq = (
        select(SharePermission.scope_id)
        .where(
            SharePermission.grantee_user_id == user_id,
            SharePermission.deleted_at.is_(None),
            SharePermission.status == "accepted",
            SharePermission.scope == "household",
        )
        .subquery()
    )

    result = await db.execute(
        select(Device.id).where(
            Device.deleted_at.is_(None),
            or_(
                Device.household_id.in_(household_subq),
                Device.id.in_(share_device_subq),
                Device.household_id.in_(share_household_subq),
            ),
        )
    )
    return list(result.scalars().all())


def _platform_admin_phones() -> set[str]:
    if not settings.PLATFORM_ADMIN_PHONES.strip():
        return set()
    return {p.strip() for p in settings.PLATFORM_ADMIN_PHONES.split(",") if p.strip()}


def is_platform_admin(user: User) -> bool:
    if user.is_platform_admin:
        return True
    return user.phone in _platform_admin_phones()


def verify_platform_admin(user: User) -> None:
    if not is_platform_admin(user):
        raise PermissionError("Platform admin access required")
