import uuid
from datetime import datetime
from sqlalchemy import String, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base, TimestampMixin, UUIDMixin, SoftDeleteMixin


class Device(UUIDMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "devices"

    serial: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    mac: Mapped[str | None] = mapped_column(String(17), nullable=True)
    device_type: Mapped[str | None] = mapped_column(String(30), nullable=True)
    model: Mapped[str | None] = mapped_column(String(50), nullable=True)
    firmware_version: Mapped[str | None] = mapped_column(String(20), nullable=True)
    name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    household_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("households.id", ondelete="SET NULL"), nullable=True
    )
    provisioned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(), nullable=False
    )
    linked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    household = relationship("Household", back_populates="devices")
    state = relationship("DeviceState", back_populates="device", uselist=False, lazy="selectin")
    events = relationship("DeviceEvent", back_populates="device", lazy="selectin")
