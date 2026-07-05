import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.dependencies import get_db
from app.schemas.auth import (
    SendOtpRequest,
    SendOtpResponse,
    VerifyOtpRequest,
    TokenResponse,
    RefreshTokenRequest,
)
from app.services.auth_service import (
    create_otp,
    verify_otp,
    recent_otp_exists,
    issue_tokens,
    refresh_tokens,
)
from app.utils.phone import validate_phone

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/send-otp", response_model=SendOtpResponse)
async def send_otp(body: SendOtpRequest, db: AsyncSession = Depends(get_db)):
    if not validate_phone(body.phone):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Invalid phone number format (expected E.164, e.g. +8613800138000)",
        )

    if await recent_otp_exists(db, body.phone):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Please wait before requesting another code",
        )

    otp = await create_otp(db, body.phone)
    logger.info("OTP for %s: %s (expires in %ss)", body.phone, otp.code, 300)

    return SendOtpResponse(expires_in_seconds=300, retry_after_seconds=60)


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp_endpoint(body: VerifyOtpRequest, db: AsyncSession = Depends(get_db)):
    if not validate_phone(body.phone):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Invalid phone number format",
        )

    user = await verify_otp(db, body.phone, body.code)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired verification code",
        )

    tokens = issue_tokens(str(user.id), user.phone)
    return TokenResponse(**tokens)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token_endpoint(body: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    tokens = refresh_tokens(body.refresh_token)
    if tokens is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
        )
    return TokenResponse(**tokens)
