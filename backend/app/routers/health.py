import logging
from fastapi import APIRouter, Request
from sqlalchemy import text
from app.database import engine

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/health")
async def health_check(request: Request):
    db_status = "disconnected"
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        db_status = "connected"
    except Exception as e:
        logger.warning("Health check DB failure: %s", e)

    mqtt_status = "disconnected"
    mqtt = getattr(request.app.state, "mqtt", None)
    if mqtt is not None and mqtt.is_connected:
        mqtt_status = "connected"

    return {
        "ok": True,
        "version": "0.1.0",
        "db": db_status,
        "mqtt": mqtt_status,
    }
