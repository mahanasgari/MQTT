import uuid
from datetime import datetime
from pydantic import BaseModel


class UserResponse(BaseModel):
    id: uuid.UUID
    phone: str
    display_name: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}
