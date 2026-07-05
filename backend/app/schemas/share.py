import uuid
from datetime import datetime
from pydantic import BaseModel


class ShareCreate(BaseModel):
    target_phone: str
    scope: str
    scope_id: uuid.UUID
    permission: str


class ShareResponse(BaseModel):
    id: uuid.UUID
    grantee_phone: str
    scope: str
    scope_id: uuid.UUID
    permission: str
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


class ShareListResponse(BaseModel):
    shares: list[ShareResponse]


class ShareUpdate(BaseModel):
    status: str


class SharedUserResponse(BaseModel):
    id: uuid.UUID
    grantee_phone: str
    permission: str
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


class SharedUserListResponse(BaseModel):
    shares: list[SharedUserResponse]
