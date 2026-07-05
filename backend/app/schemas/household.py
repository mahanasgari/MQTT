import uuid
from datetime import datetime
from pydantic import BaseModel


class HouseholdCreate(BaseModel):
    name: str
    timezone: str = "UTC"


class HouseholdUpdate(BaseModel):
    name: str | None = None
    timezone: str | None = None


class HouseholdResponse(BaseModel):
    id: uuid.UUID
    name: str
    timezone: str
    role: str = "member"
    device_count: int = 0
    created_at: datetime

    model_config = {"from_attributes": True}


class HouseholdListResponse(BaseModel):
    households: list[HouseholdResponse]
