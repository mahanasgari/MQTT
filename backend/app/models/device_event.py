import uuid
from datetime import datetime
from sqlalchemy import String, ForeignKey, DateTime, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base, UUIDMixin


class DeviceEvent(UUIDMixin, Base):
    __tablename__ = "device_events"

    device_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("devices.id", ondelete="CASCADE"), nullable=False, index=True
    )
    type: Mapped[str] = mapped_column(String(30), nullable=False)
    initiator: Mapped[str] = mapped_column(String(20), nullable=False)
    initiator_id: Mapped[uuid.UUID | None] = mapped_column(nullable=True)
    payload: Mapped[dict | None] = mapped_column("metadata", JSON, nullable=True)
    occurred_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, index=True
    )

    device = relationship("Device", back_populates="events")
