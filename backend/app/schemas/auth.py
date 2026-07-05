from pydantic import BaseModel


class SendOtpRequest(BaseModel):
    phone: str


class SendOtpResponse(BaseModel):
    expires_in_seconds: int
    retry_after_seconds: int


class VerifyOtpRequest(BaseModel):
    phone: str
    code: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int


class RefreshTokenRequest(BaseModel):
    refresh_token: str
