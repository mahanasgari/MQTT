# Server Architecture

Production architecture for multi-device smart homes: how the FastAPI backend, PostgreSQL, Mosquitto, Nginx, and clients work together. Includes the full **device command flow** from mobile ON button to relay and real-time UI update.

## System context

```
┌─────────────────────────────────────────────────────────────────┐
│                         Linux VPS                                │
│                                                                  │
│  ┌──────────┐    ┌─────────────────────────────────────────┐  │
│  │  Nginx   │───►│ FastAPI (Uvicorn)                        │  │
│  │  :443    │    │  REST /v1/*  ·  WebSocket /v1/ws         │  │
│  └──────────┘    │  MQTTService  ·  RealtimeService         │  │
│                  └───────┬─────────────────┬─────────────────┘  │
│                          │                 │                     │
│              ┌───────────▼───┐     ┌───────▼────────┐           │
│              │ PostgreSQL 15 │     │   Mosquitto    │           │
│              │ device_states │     │  tele/* cmnd/* │           │
│              │ device_events │     └───────┬────────┘           │
│              └───────────────┘             │                     │
└────────────────────────────────────────────┼─────────────────────┘
                                             │ MQTT
                                    ┌────────▼────────┐
                                    │  Home network      │
                                    │  ESP8266 × N       │
                                    └───────────────────┘

┌─────────────┐     HTTPS/WSS      ┌─────────────┐
│ Flutter app │◄──────────────────►│   Nginx     │
└─────────────┘                    └─────────────┘
┌─────────────┐     HTTPS/WSS      │
│ Next.js web │◄──────────────────┘
└─────────────┘
```

**Source of truth docs:** [architecture.md](architecture.md), [api_contract.md](api_contract.md), [db_schema.md](db_schema.md)

## Core services (backend)

| Service | File | Responsibility |
|---------|------|----------------|
| HTTP API | `backend/app/routers/*` | Auth, households, devices, shares, events |
| MQTT client | `backend/app/services/mqtt_service.py` | Subscribe telemetry, publish commands |
| Device logic | `backend/app/services/device_service.py` | Persist state/events from MQTT |
| Access control | `backend/app/services/access_control.py` | Permission checks |
| Realtime | `backend/app/services/realtime_service.py` | WebSocket fan-out |
| WebSocket router | `backend/app/routers/ws.py` | JWT auth, subscribe protocol |
| App lifecycle | `backend/app/main.py` | Wire MQTT → Realtime on state change |

## Data model (multi-device)

```mermaid
erDiagram
    users ||--o{ household_members : has
    households ||--o{ household_members : contains
    households ||--o{ devices : owns
    users ||--o{ share_permissions : grants
    devices ||--|| device_states : has
    devices ||--o{ device_events : logs
    devices ||--o| device_network_config : reports
```

### One user, many devices

- A user may belong to **multiple households** (`household_members`)
- Each household has **many devices** (`devices.household_id`)
- A user sees the **union** of:
  - All devices in households they belong to
  - All devices shared via `share_permissions` (device or household scope)

### Discovery and listing

**Endpoint:** `GET /v1/devices`

Query parameters:

- `household_id` — filter to one home
- `linked=true|false` — filter linked vs unlinked

**Implementation:** `list_accessible_device_ids()` in `access_control.py` builds OR query:

1. `devices.household_id IN (user's households)`
2. `devices.id IN (accepted device-scope shares)`
3. `devices.household_id IN (accepted household-scope shares)`

Returns `DeviceListResponse` with current `state` embedded when `device_states` row exists.

**Mobile:** `DeviceRepository.list()` → dashboard cards  
**Web:** `GET /devices` via `frontend/src/lib/api.ts`

### Real-time state (all owned devices)

Clients do **not** use MQTT. They use WebSocket:

**Connect:** `wss://api.smartplug.example.com/v1/ws?token=<JWT access token>`

**Subscribe:**

```json
{ "type": "subscribe", "device_ids": ["uuid-1", "uuid-2", "uuid-3"] }
```

Server validates user has `view` permission on each ID, then registers socket in `RealtimeService`.

**Inbound message types** (from server):

| type | When |
|------|------|
| `state_update` | MQTT `tele/{serial}/state` processed |
| `device_event` | MQTT `tele/{serial}/event` processed |
| `connectivity_change` | MQTT `tele/{serial}/online` processed |
| `subscribed` | Ack subscribe |
| `error` | Invalid JSON or permission denied |

**Flow:** MQTT message → DB commit → `mqtt.on_state_change` callback in `main.py` → `realtime.broadcast(device_id, ...)`

### State storage pattern

| Store | Purpose | Mutability |
|-------|---------|------------|
| `device_states` | Current power, connectivity, last_seen | Updated on each MQTT state/online |
| `device_events` | Immutable audit log | Append-only |

Event types include `power_on`, `power_off`, `device_online`, `device_offline`, `provisioned`, `linked`.

REST fallback: `GET /v1/devices/{id}`, `GET /v1/devices/{id}/state`, `GET /v1/devices/{id}/events`

## Cloud / local hybrid control paths

From [architecture.md](architecture.md) §2:

| Scenario | Control path | State sync |
|----------|--------------|------------|
| Device online, cloud reachable | App → REST → Backend → MQTT → Device | Device → MQTT → Backend → WebSocket → App |
| Device online, no internet | App on LAN → Local MQTT → Device | LAN only; buffer until cloud returns |
| Cloud up, app not on LAN | App → REST/WS → Backend → Cloud MQTT → Device | Same as row 1 |

v1 production deployment focuses on **cloud path**. Local MQTT is firmware/LAN ops concern; document broker on customer router if offering hybrid SKU.

## Multi-device scaling (v1 vs future)

### v1 — single VPS (recommended launch)

- 1× Uvicorn with 2–4 workers
- 1× Mosquitto on same host
- 1× PostgreSQL
- In-memory `RealtimeService` (no Redis)

Suitable for thousands of devices with modest concurrent WebSocket connections.

### Future horizontal scaling

| Component | Challenge | Mitigation |
|-----------|-----------|------------|
| FastAPI replicas | WebSocket sticky sessions | IP hash in Nginx or Redis pub/sub bridge |
| RealtimeService | Per-process memory | Redis channels for broadcast |
| MQTT | Single broker throughput | EMQX cluster or shard by region |
| PostgreSQL | Write-heavy `device_events` | Partition by month, read replicas |

Not required for initial commercial launch on one VPS.

---

## Device command flow (full trace)

Example: user presses **ON** in the Flutter app for `Living Room Plug` (`SN-2026-000001`).

### Overview diagram

```mermaid
sequenceDiagram
    participant App as Flutter_App
    participant Nginx
    participant API as FastAPI
    participant AC as AccessControl
    participant MQTT as Mosquitto
    participant ESP as ESP8266
    participant DB as PostgreSQL
    participant RT as RealtimeService
    participant WS as WebSocket

    App->>Nginx: PATCH /v1/devices/{id}/control
    Nginx->>API: proxy HTTPS
    API->>AC: require_device_permission control
    AC->>DB: Check household and shares
    AC-->>API: Device authorized
    API->>MQTT: PUBLISH cmnd/SN-2026-000001/power on
    API-->>App: 200 status accepted

    MQTT->>ESP: Deliver command QoS1
    ESP->>ESP: GPIO relay ON
    ESP->>MQTT: PUBLISH tele/SN-2026-000001/state
  ESP->>MQTT: PUBLISH tele/SN-2026-000001/event optional

    MQTT->>API: handle_state_message
    API->>DB: UPDATE device_states power on
    API->>DB: INSERT device_events power_on
    API->>RT: broadcast state_update
    RT->>WS: JSON to subscribed clients
    WS->>App: state_update power on
```

### Step 1 — User action (Flutter)

**UI:** `DeviceDetailScreen` or home card → `_toggle()` / control provider

**HTTP:**

```http
PATCH /v1/devices/3fa85f64-5717-4562-b3fc-2c963f66afa6/control
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json

{"command": "power", "value": "on"}
```

**Client code:** `DeviceRepository.control()` → `ApiClient.patch`

### Step 2 — Nginx → FastAPI

Nginx terminates TLS, forwards to `127.0.0.1:8000`.

Router: `backend/app/routers/devices.py` → `control_device()`

### Step 3 — Authentication

`get_current_user` dependency validates JWT from `Authorization` header (see `dependencies.py`).

Invalid/expired token → **401 Unauthorized**

### Step 4 — Authorization

`device: Device = Depends(require_device_permission("control"))`

`verify_device_access()` checks:

- Device exists, not soft-deleted
- Effective permission ≥ `control` via household role or accepted share

Failures:

- **403 Forbidden** — no permission
- **404** — device not found

Additional check:

```python
if device.household_id is None:
    raise HTTPException(400, "Device not linked to a household")
```

### Step 5 — MQTT publish

```python
await mqtt.publish_command(device.serial, body.command, body.value)
# → topic: cmnd/SN-2026-000001/power
# → payload: on
# → QoS: 1
```

Implementation: `MQTTService.publish_command()` in `mqtt_service.py`

Failure (broker down) → **502 Bad Gateway** `"MQTT publish failed"`

Success → **200** `{"status": "accepted"}`

**Note:** Response is **accepted**, not confirmed. Relay state is confirmed asynchronously via telemetry.

### Step 6 — Mosquitto → ESP8266

Broker delivers to subscriber on `cmnd/SN-2026-000001/power`.

Firmware handler:

1. Parse payload `on` / `off`
2. Drive relay GPIO
3. Update local state machine

If device offline: message queued per QoS 1 until session resumes or times out.

### Step 7 — ESP8266 reports new state

Firmware publishes:

**Topic:** `tele/SN-2026-000001/state`

```json
{
  "power": "on",
  "connectivity": "online",
  "last_changed_at": "2026-06-29T14:30:00Z"
}
```

Optionally `tele/SN-2026-000001/event`:

```json
{
  "type": "power_on",
  "occurred_at": "2026-06-29T14:30:00Z"
}
```

### Step 8 — Backend MQTT handler

`MQTTService._on_message()`:

1. Parse topic → serial `SN-2026-000001`, suffix `state`
2. `handle_state_message(session, serial, data)`
3. Lookup device by serial — must exist
4. Compare previous power; if changed, insert `device_events` (`power_on`)
5. Upsert `device_states`
6. `session.commit()`
7. `_notify_state_change(device_id, "state", data)`

### Step 9 — WebSocket broadcast

`main.py` callback:

```python
await realtime.broadcast(device_id, "state_update", data)
```

`RealtimeService.broadcast()` sends to all WebSockets subscribed to that `device_id`:

```json
{
  "type": "state_update",
  "device_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "power": "on",
    "connectivity": "online",
    "last_changed_at": "2026-06-29T14:30:00Z"
  }
}
```

### Step 10 — Flutter UI update

WebSocket listener in `ws_provider` / device detail provider applies payload → rebuilds UI (power toggle shows ON).

If WebSocket disconnected, UI may poll `GET /v1/devices/{id}` or refresh on reconnect.

---

## Parallel path: Next.js web dashboard

Identical backend path:

1. `PowerToggle` component → `api.patch(/devices/${id}/control, ...)`
2. Same auth, access control, MQTT publish
3. WebSocket via `frontend/src/lib/ws.ts` — connect with `?token=`, subscribe to device IDs
4. `DashboardDeviceCard` updates on `state_update`

CORS must allow `https://app.smartplug.example.com` in `CORS_ORIGINS`.

---

## Failure modes and HTTP codes

| Condition | HTTP | User-visible behavior |
|-----------|------|------------------------|
| Not logged in | 401 | Redirect to login |
| Sharee with view only | 403 | Control disabled in UI |
| Device unlinked | 400 | Prompt to complete setup |
| MQTT broker down | 502 | Error toast; retry |
| Device offline | 200 accepted | No state change until online |
| Unknown serial on MQTT | N/A (dropped) | Logs only; fix registration |
| Stale WebSocket | — | Reconnect + resubscribe |

### Offline device

`PATCH /control` may return **200 accepted** even if device is disconnected. Mosquitto queues QoS 1 for clean session; otherwise command is lost. UI should show `connectivity: offline` from last `device_states`.

### Optimistic UI

Mobile/web may toggle UI before MQTT round-trip; rollback if no `state_update` within timeout (app-specific).

---

## Sharing and multi-user control

When owner shares device with `control` permission:

1. Sharee logs in with their phone
2. `list_accessible_device_ids` includes shared device
3. Sharee's `PATCH /control` passes `verify_device_access`
4. Same MQTT publish path — **initiator_id** in events is not set for MQTT-driven events (device initiator)

Household **admin** shares use `POST /v1/shares` with `scope: device` or `household`.

---

## Security boundaries

| Layer | Mechanism |
|-------|-----------|
| Transport | TLS (Nginx), optional MQTT TLS |
| API auth | JWT access token (short-lived) |
| Device auth | Mosquitto username/password + ACL |
| Authorization | Household role + share permissions |
| MQTT isolation | Per-device topic ACL |

Devices never receive user JWTs. Users never receive MQTT credentials (backend only).

---

## Monitoring hooks

| Signal | Source |
|--------|--------|
| API health | `GET /health` |
| MQTT connected | Backend startup log |
| Device online count | SQL `device_states WHERE connectivity='online'` |
| Broker clients | Mosquitto `$SYS/broker/clients/connected` |
| Command failures | Log `Failed to publish MQTT command` |
| WS fan-out | Log `WS send error` in realtime_service |

---

## Related documents

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) — deploy FastAPI, Nginx, Postgres
- [MQTT_SETUP.md](MQTT_SETUP.md) — topics and broker security
- [DEVICE_REGISTRATION_FLOW.md](DEVICE_REGISTRATION_FLOW.md) — ownership before control
- [DEVICE_PROVISIONING_FLOW.md](DEVICE_PROVISIONING_FLOW.md) — first-time setup
- [api_contract.md](api_contract.md) — complete API reference
