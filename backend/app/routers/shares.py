import uuid
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.dependencies import get_db, get_current_user
from app.models.user import User
from app.models.share_permission import SharePermission
from app.schemas.share import (
    ShareCreate,
    ShareResponse,
    ShareListResponse,
    ShareUpdate,
)
from app.services.access_control import get_effective_permission
from app.utils.phone import validate_phone

logger = logging.getLogger(__name__)
router = APIRouter()


async def _share_to_response(s: SharePermission) -> ShareResponse:
    return ShareResponse(
        id=s.id,
        grantee_phone=s.grantee_phone,
        scope=s.scope,
        scope_id=s.scope_id,
        permission=s.permission,
        status=s.status,
        created_at=s.created_at,
    )


@router.post("", response_model=ShareResponse, status_code=status.HTTP_201_CREATED)
async def create_share(
    body: ShareCreate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if not validate_phone(body.target_phone):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Invalid phone number format",
        )
    if body.scope not in ("device", "household"):
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="scope must be 'device' or 'household'")
    if body.permission not in ("view", "control", "admin"):
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="permission must be 'view', 'control', or 'admin'")

    if body.scope == "device":
        try:
            perm = await get_effective_permission(db, user.id, body.scope_id)
        except Exception:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
        if perm is None:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Device not found or no access")
        from app.services.access_control import PERMISSION_ORDER
        if PERMISSION_ORDER.get(perm, -1) < PERMISSION_ORDER.get("admin", 2):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin permission required to share this device")
    else:
        from app.models.household import Household
        household = await db.get(Household, body.scope_id)
        if household is None or household.deleted_at is not None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Household not found")
        from app.services.access_control import verify_household_role
        try:
            await verify_household_role(db, user.id, body.scope_id, "admin")
        except PermissionError:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin role required in this household")

    share = SharePermission(
        granted_by=user.id,
        grantee_phone=body.target_phone,
        scope=body.scope,
        scope_id=body.scope_id,
        permission=body.permission,
        status="pending",
    )
    db.add(share)
    await db.commit()
    await db.refresh(share)
    return await _share_to_response(share)


@router.get("", response_model=ShareListResponse)
async def list_shares(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(SharePermission)
        .where(SharePermission.granted_by == user.id, SharePermission.deleted_at.is_(None))
        .order_by(SharePermission.created_at.desc())
    )
    shares = result.scalars().all()
    items = [await _share_to_response(s) for s in shares]
    return ShareListResponse(shares=items)


@router.get("/incoming", response_model=ShareListResponse)
async def incoming_shares(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(SharePermission)
        .where(
            SharePermission.grantee_phone == user.phone,
            SharePermission.deleted_at.is_(None),
        )
        .order_by(SharePermission.created_at.desc())
    )
    shares = result.scalars().all()
    items = [await _share_to_response(s) for s in shares]
    return ShareListResponse(shares=items)


@router.patch("/{share_id}", response_model=ShareResponse)
async def update_share(
    share_id: uuid.UUID,
    body: ShareUpdate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if body.status not in ("accepted", "declined"):
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="status must be 'accepted' or 'declined'")

    share = await db.get(SharePermission, share_id)
    if share is None or share.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Share not found")
    if share.grantee_phone != user.phone:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the grantee can accept or decline")

    share.status = body.status
    share.grantee_user_id = user.id
    await db.commit()
    await db.refresh(share)
    return await _share_to_response(share)


@router.delete("/{share_id}")
async def revoke_share(
    share_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    share = await db.get(SharePermission, share_id)
    if share is None or share.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Share not found")
    if share.granted_by != user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the granter can revoke")

    from datetime import datetime, timezone
    share.deleted_at = datetime.now(timezone.utc)
    await db.commit()
    return {"status": "revoked"}
