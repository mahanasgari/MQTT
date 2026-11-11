import uuid
from datetime import datetime
from pydantic import BaseModel


class DeviceStateResponse(BaseModel):
    power: str
    connectivity: str
    last_changed_at: datetime
    last_seen_at: datetime

    model_config = {"from_attributes": True}


class DeviceFullStateResponse(BaseModel):
    power: str
    connectivity: str
    voltage: float | None = None
    current: float | None = None
    power_consumption: float | None = None
    last_changed_at: datetime
    last_seen_at: datetime

    model_config = {"from_attributes": True}


class DeviceResponse(BaseModel):
    id: uuid.UUID
    serial: str
    name: str | None = None
    household_id: uuid.UUID | None = None
    firmware_version: str | None = None
    state: DeviceStateResponse | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class DeviceListResponse(BaseModel):
    devices: list[DeviceResponse]


class DeviceUpdate(BaseModel):
    name: str | None = None


class DeviceLinkRequest(BaseModel):
    household_id: uuid.UUID
    name: str | None = None


class DeviceControlRequest(BaseModel):
    command: str
    value: str


class DeviceSimulateRequest(BaseModel):
    power: str | None = None
    connectivity: str | None = "online"


class LocalTestDeviceRequest(BaseModel):
    name: str | None = None
    household_id: uuid.UUID | None = None


class DeviceRegisterRequest(BaseModel):
    serial: str
    token: str
    name: str | None = None


class ProvisionPairingTokenRequest(BaseModel):
    household_id: uuid.UUID | None = None
    serial: str | None = None


class PairingTokenCreateRequest(BaseModel):
    household_id: uuid.UUID | None = None


class PairingTokenResponse(BaseModel):
    id: uuid.UUID
    token: str
    status: str
    expires_at: datetime

    model_config = {"from_attributes": True}


class DeviceEventResponse(BaseModel):
    id: uuid.UUID
    device_id: uuid.UUID
    type: str
    initiator: str
    initiator_id: uuid.UUID | None = None
    metadata: dict | None = None
    occurred_at: datetime

    model_config = {"from_attributes": True, "populate_by_name": True}


class DeviceEventListResponse(BaseModel):
    events: list[DeviceEventResponse]
    total: int
