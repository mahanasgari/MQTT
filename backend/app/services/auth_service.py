import secrets
import logging
from datetime import datetime, timedelta, timezone
from jose import jwt, JWTError
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.models.user import User, OtpCode

logger = logging.getLogger(__name__)


def generate_otp(length: int | None = None) -> str:
    length = length or settings.OTP_LENGTH
    fmt = f"%0{length}d"
    return fmt % secrets.randbelow(10**length)


async def create_otp(db: AsyncSession, phone: str) -> OtpCode:
    code = generate_otp()
    otp = OtpCode(
        phone=phone,
        code=code,
        expires_at=datetime.now(timezone.utc) + timedelta(seconds=settings.OTP_EXPIRE_SECONDS),
    )
    db.add(otp)
    await db.commit()
    return otp


async def verify_otp(db: AsyncSession, phone: str, code: str) -> User | None:
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(OtpCode)
        .where(OtpCode.phone == phone, OtpCode.code == code, OtpCode.used == False)
        .order_by(OtpCode.expires_at.desc())
        .limit(1)
    )
    otp = result.scalar_one_or_none()
    if otp is None or otp.expires_at < now:
        return None

    otp.used = True

    result = await db.execute(select(User).where(User.phone == phone))
    user = result.scalar_one_or_none()
    if user is None:
        user = User(phone=phone)
        db.add(user)

    await db.commit()
    await db.refresh(user)
    return user


async def recent_otp_exists(db: AsyncSession, phone: str) -> bool:
    since = datetime.now(timezone.utc) - timedelta(seconds=settings.OTP_RETRY_AFTER_SECONDS)
    result = await db.execute(
        select(OtpCode)
        .where(OtpCode.phone == phone, OtpCode.created_at > since)
        .limit(1)
    )
    return result.scalar_one_or_none() is not None


def create_access_token(subject: str, phone: str, expires_delta: timedelta | None = None) -> str:
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode = {"sub": subject, "phone": phone, "exp": expire, "type": "access"}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")


def create_refresh_token(subject: str, phone: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=30)
    to_encode = {"sub": subject, "phone": phone, "exp": expire, "type": "refresh"}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")


def decode_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
    except JWTError:
        return None


def issue_tokens(user_id: str, phone: str) -> dict:
    return {
        "access_token": create_access_token(user_id, phone),
        "refresh_token": create_refresh_token(user_id, phone),
        "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    }


def refresh_tokens(refresh_token: str) -> dict | None:
    payload = decode_token(refresh_token)
    if payload is None or payload.get("type") != "refresh":
        return None
    return issue_tokens(payload["sub"], payload["phone"])
