"""Device event history router.
Extend here: query events with pagination and filters.
"""
from fastapi import APIRouter

router = APIRouter()


@router.get("/{device_id}/events")
async def list_device_events(device_id: str):
    """List events for a device. TODO: implement."""
    return {"message": "not implemented", "device_id": device_id}
