import uuid
from datetime import datetime
from pydantic import BaseModel, Field


class DeviceEventResponse(BaseModel):
    id: uuid.UUID
    device_id: uuid.UUID
    type: str
    initiator: str
    initiator_id: uuid.UUID | None = None
    metadata: dict | None = Field(None, validation_alias="payload")
    occurred_at: datetime

    model_config = {"from_attributes": True, "populate_by_name": True}


class DeviceEventListResponse(BaseModel):
    events: list[DeviceEventResponse]
    total: int
