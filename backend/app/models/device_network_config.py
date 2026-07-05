import uuid
from datetime import datetime
from sqlalchemy import String, ForeignKey, DateTime, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base, UUIDMixin, TimestampMixin


class DeviceNetworkConfig(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "device_network_config"

    device_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("devices.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    ip_address: Mapped[str | None] = mapped_column(String(45), nullable=True)
    mac_address: Mapped[str | None] = mapped_column(String(17), nullable=True)
    wifi_ssid: Mapped[str | None] = mapped_column(String(100), nullable=True)
    wifi_rssi: Mapped[int | None] = mapped_column(nullable=True)
    gateway_ip: Mapped[str | None] = mapped_column(String(45), nullable=True)
    firmware_version: Mapped[str | None] = mapped_column(String(20), nullable=True)
    last_seen_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    device = relationship("Device")
