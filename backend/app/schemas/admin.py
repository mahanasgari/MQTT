import uuid
from datetime import datetime
from pydantic import BaseModel
from app.schemas.device import DeviceResponse, PairingTokenResponse, DeviceEventResponse


class AdminStatsResponse(BaseModel):
    users: int
    households: int
    devices: int
    devices_online: int
    devices_linked: int


class AdminUserResponse(BaseModel):
    id: uuid.UUID
    phone: str
    display_name: str | None
    is_platform_admin: bool
    created_at: datetime


class AdminUserListResponse(BaseModel):
    users: list[AdminUserResponse]
    total: int


class AdminDeviceListResponse(BaseModel):
    devices: list[DeviceResponse]
    total: int


class AdminHouseholdResponse(BaseModel):
    id: uuid.UUID
    name: str
    timezone: str
    member_count: int
    device_count: int
    created_at: datetime


class AdminHouseholdListResponse(BaseModel):
    households: list[AdminHouseholdResponse]
    total: int


class AdminDeviceCreateRequest(BaseModel):
    serial: str
    name: str | None = None
    model: str | None = None
    mac: str | None = None


class AdminDeviceUpdateRequest(BaseModel):
    name: str | None = None
    household_id: uuid.UUID | None = None
    unlink: bool = False
    soft_delete: bool = False


class AdminPairingTokenRequest(BaseModel):
    serial: str | None = None
    household_id: uuid.UUID | None = None


class AdminEventListResponse(BaseModel):
    events: list[DeviceEventResponse]
    total: int
