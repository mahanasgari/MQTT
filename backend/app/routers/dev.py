import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
from app.config import settings
from app.dependencies import get_db
from app.models.user import OtpCode
from app.utils.phone import validate_phone

logger = logging.getLogger(__name__)
router = APIRouter()


class DevOtpResponse(BaseModel):
    phone: str
    code: str
    expires_at: str


@router.get("/dev/otp/{phone}", response_model=DevOtpResponse)
async def get_dev_otp(phone: str, db: AsyncSession = Depends(get_db)):
    if settings.ENVIRONMENT == "production":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if not validate_phone(phone):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Invalid phone number format (expected E.164)",
        )

    result = await db.execute(
        select(OtpCode)
        .where(OtpCode.phone == phone, OtpCode.used == False)
        .order_by(OtpCode.created_at.desc())
        .limit(1)
    )
    otp = result.scalar_one_or_none()
    if otp is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No unused OTP found for this phone number",
        )

    return DevOtpResponse(
        phone=otp.phone,
        code=otp.code,
        expires_at=otp.expires_at.isoformat(),
    )
