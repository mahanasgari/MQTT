import uuid
from datetime import datetime
from sqlalchemy import String, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base, TimestampMixin


class DeviceState(TimestampMixin, Base):
    __tablename__ = "device_states"

    device_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("devices.id", ondelete="CASCADE"), primary_key=True
    )
    power: Mapped[str] = mapped_column(String(4), nullable=False, default="off")
    connectivity: Mapped[str] = mapped_column(String(10), nullable=False, default="offline")
    last_changed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(), nullable=False
    )
    last_seen_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(), nullable=False
    )
    voltage: Mapped[float | None] = mapped_column(nullable=True)
    current: Mapped[float | None] = mapped_column(nullable=True)
    power_consumption: Mapped[float | None] = mapped_column(nullable=True)

    device = relationship("Device", back_populates="state")
