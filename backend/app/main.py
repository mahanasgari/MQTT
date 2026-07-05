import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from app.config import settings
from app.database import engine
from app.logging_conf import configure_logging
from app.exceptions import register_exception_handlers
from app.services.mqtt_service import MQTTService
from app.services.realtime_service import RealtimeService
from app.routers import health, auth, households, devices, shares, ws, dev, admin

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    configure_logging()
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        logger.info("Database connection OK")
    except Exception as e:
        logger.warning("Database not reachable at startup: %s", e)

    mqtt = MQTTService()
    realtime = RealtimeService()

    async def on_mqtt_state_change(device_id, suffix, data):
        if suffix == "state":
            await realtime.broadcast(device_id, "state_update", data)
        elif suffix == "event":
            await realtime.broadcast(device_id, "device_event", data)
        elif suffix == "online":
            connectivity = data.get("status", data.get("connectivity", "online"))
            await realtime.broadcast(
                device_id, "connectivity_change", {"connectivity": connectivity}
            )

    mqtt.on_state_change(on_mqtt_state_change)

    try:
        await mqtt.start()
        logger.info("MQTT service started")
    except Exception as e:
        logger.warning("MQTT broker not reachable at startup: %s", e)

    app.state.mqtt = mqtt
    app.state.realtime = realtime

    yield

    await mqtt.stop()
    await engine.dispose()
    logger.info("Shutdown complete")


app = FastAPI(
    title="SmartPlug API",
    version=settings.APP_VERSION,
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

register_exception_handlers(app)

app.include_router(health.router, tags=["health"])
app.include_router(auth.router, prefix="/v1/auth", tags=["auth"])
app.include_router(households.router, prefix="/v1/households", tags=["households"])
app.include_router(devices.router, prefix="/v1/devices", tags=["devices"])
app.include_router(shares.router, prefix="/v1/shares", tags=["shares"])
app.include_router(ws.router, prefix="/v1", tags=["ws"])
app.include_router(dev.router, prefix="/v1", tags=["dev"])
app.include_router(admin.router, prefix="/v1/admin", tags=["admin"])
