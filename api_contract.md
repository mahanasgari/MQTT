# API Contract

Base URL: `https://api.example.com/v1`

Auth header: `Authorization: Bearer <access_token>`

## 1. Authentication

### `POST /auth/send-otp`
Send OTP to phone number.

Request:
```json
{ "phone": "+8613800138000" }
```
Response `200`:
```json
{ "expires_in_seconds": 300, "retry_after_seconds": 60 }
```

### `POST /auth/verify-otp`
Verify OTP and receive tokens.

Request:
```json
{ "phone": "+8613800138000", "code": "123456" }
```
Response `200`:
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "expires_in": 3600
}
```

### `POST /auth/refresh`
Refresh access token.

Request:
```json
{ "refresh_token": "eyJ..." }
```
Response `200`:
```json
{ "access_token": "eyJ...", "expires_in": 3600 }
```

## 2. Households

### `POST /households`
Create a household.

Request:
```json
{ "name": "Home", "timezone": "Asia/Shanghai" }
```
Response `201`:
```json
{ "id": "uuid", "name": "Home", "timezone": "Asia/Shanghai", "created_at": "..." }
```

### `GET /households`
List user's households.

Response `200`:
```json
{
  "households": [
    { "id": "uuid", "name": "Home", "device_count": 3, "role": "admin" }
  ]
}
```

### `GET /households/{id}`
Get household details.

### `PATCH /households/{id}`
Update household name/timezone.

### `DELETE /households/{id}`
Delete household (must be empty).

## 3. Devices

### `GET /devices`
List user's devices. Query params: `?household_id=uuid&linked=true|false`

Response `200`:
```json
{
  "devices": [
    {
      "id": "uuid",
      "serial": "SP123456789",
      "name": "Living Room Plug",
      "household_id": "uuid",
      "firmware_version": "2.1.0",
      "created_at": "..."
    }
  ]
}
```

### `GET /devices/{id}`
Get device details, including current state.

Response `200`:
```json
{
  "id": "uuid",
  "serial": "SP123456789",
  "name": "Living Room Plug",
  "household_id": "uuid",
  "state": {
    "power": "on",
    "connectivity": "online",
    "last_changed_at": "2025-06-10T12:00:00Z",
    "last_seen_at": "2025-06-10T12:05:00Z"
  }
}
```

### `PATCH /devices/{id}`
Update device name.

Request:
```json
{ "name": "Kitchen Plug" }
```

### `PATCH /devices/{id}/link`
Link unlinked device to household.

Request:
```json
{ "household_id": "uuid", "name": "Living Room" }
```

### `PATCH /devices/{id}/control`
Send control command.

Request:
```json
{ "command": "power", "value": "on" }
```
Response `202`:
```json
{ "status": "accepted" }
```
Backend publishes `cmnd/{serial}/power` → `on` via MQTT.

### `DELETE /devices/{id}`
Unlink/remove device from household (device record persists).

## 4. Real-time State

### `WebSocket /ws/devices/{id}/state`
Requires JWT auth via query param: `?token=eyJ...`

Server pushes state updates:
```json
{
  "type": "state_update",
  "data": {
    "power": "on",
    "connectivity": "online",
    "last_changed_at": "2025-06-10T12:00:00Z"
  }
}
```

### `WebSocket /ws/devices`
Subscribe to all devices the user has access to.

## 5. Events

### `GET /devices/{id}/events`
Query params: `?limit=50&offset=0&from=ISO8601&to=ISO8601`

Response `200`:
```json
{
  "events": [
    {
      "id": "uuid",
      "device_id": "uuid",
      "type": "power_on",
      "initiator": "user",
      "initiator_id": "user_uuid",
      "metadata": { "source": "app" },
      "occurred_at": "2025-06-10T12:00:00Z"
    }
  ],
  "total": 1
}
```

Event types: `power_on`, `power_off`, `device_online`, `device_offline`, `provisioned`, `linked`

## 6. Sharing

### `POST /shares`
Create share.

Request:
```json
{
  "target_phone": "+8613800138001",
  "scope": "device",
  "scope_id": "device_uuid",
  "permission": "control"
}
```
`scope`: `"household"` | `"device"`
`permission`: `"view"` | `"control"` | `"admin"`

Response `201`:
```json
{ "id": "uuid", "status": "pending" }
```

### `GET /shares`
List shares created by me.

### `GET /shares/incoming`
List shares shared with me.

### `PATCH /shares/{id}`
Accept/decline share.

Request:
```json
{ "status": "accepted" }
```

### `DELETE /shares/{id}`
Revoke share.

## 7. MQTT Topics

### Backend Subscribes

| Topic | Handler | Payload | Description |
|---|---|---|---|
| `tele/+/state` | `handle_state_message` | `{"power":"on\|off","connectivity":"online\|offline","last_changed_at":"ISO8601"}` | Upserts `device_states`, creates event if power changed |
| `tele/+/event` | `handle_event_message` | `{"type":"power_on\|power_off\|device_online\|device_offline","occurred_at":"ISO8601"}` | Inserts `device_event`, updates `device_states` accordingly |
| `tele/+/online` | `handle_availability_message` | `{"status":"online","ip":"...","mac":"..."}` | Updates connectivity, upserts `device_network_config`, creates event |

### Backend Publishes

| Topic | Payload | Description |
|---|---|---|
| `cmnd/{serial}/{command}` | `"on"` or `"off"` | Control command (e.g. `cmnd/SP123456789/power`) |
| `config/{serial}` | `{"interval":60,"broker":"..."}` | Device configuration (future) |

### Payload Details

**`tele/{serial}/state`** — sent by device on state change or periodically:
```json
{
  "power": "on",
  "connectivity": "online",
  "last_changed_at": "2025-06-10T12:00:00Z"
}
```

**`tele/{serial}/event`** — immutable event log entry:
```json
{
  "type": "power_on",
  "occurred_at": "2025-06-10T12:00:00Z",
  "voltage": 220.5,
  "current": 0.5
}
```

**`tele/{serial}/online`** — birth message (retained) or LWT:
```json
{
  "status": "online",
  "ip": "192.168.1.5",
  "mac": "aa:bb:cc:dd:ee:ff",
  "firmware_version": "2.1.0",
  "rssi": -65
}
```
When the device unexpectedly disconnects, Mosquitto publishes a retained empty message (or LWT) on this topic. The backend treats the absence or an explicit `{"status": "offline"}` as an offline event.

### Backend subscription behaviour
- All three wildcard subscriptions are registered on MQTT connect.
- Messages are processed asynchronously; database commit per message.
- Unknown device serials are logged and skipped (device must be provisioned first).

## 8. Error Responses

All errors follow RFC 7807:

```json
{
  "type": "validation_error",
  "title": "Validation Error",
  "detail": "phone: Invalid phone number format",
  "status": 422
}
```

Common status codes:
- `400` — bad request
- `401` — unauthenticated
- `403` — forbidden (no permission)
- `404` — not found
- `409` — conflict (e.g. device already linked)
- `422` — validation error
- `429` — rate limited
