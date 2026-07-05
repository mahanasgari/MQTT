# Architecture

## 1. System Context

```
┌──────────────┐      ┌─────────────────┐      ┌──────────────┐
│   Flutter     │      │    Next.js       │      │   Device     │
│   Mobile App  │      │   Web App        │      │  (ESP32/ESP) │
└──────┬───────┘      └───────┬─────────┘      └──────┬───────┘
       │                      │                        │
       │   HTTPS/WSS          │   HTTPS/WSS            │  MQTT
       ▼                      ▼                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    Cloud Backend                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  FastAPI (Uvicorn)                                     │  │
│  │  REST endpoints · WebSocket · MQTT client              │  │
│  └────────────┬───────────────────────────────────────────┘  │
│               │                                              │
│  ┌────────────▼──────────┐   ┌──────────────────────────┐   │
│  │   PostgreSQL          │   │   MQTT Broker (Cloud)    │   │
│  │   Relational + Events │   │   emqx / mosquitto       │   │
│  └───────────────────────┘   └──────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
                               │
                         MQTT (WAN)
                               │
                    ┌──────────▼──────────┐
                    │   Home Network       │
                    │  ┌────────────────┐  │
                    │  │ Local MQTT     │  │
                    │  │ Broker (LAN)   │  │
                    │  └───────┬────────┘  │
                    │          │            │
                    │  ┌───────▼────────┐  │
                    │  │   Device       │  │
                    │  │  (Smart Plug)  │  │
                    │  └────────────────┘  │
                    └──────────────────────┘
```

## 2. Cloud/Local Hybrid Behavior

| Scenario | Control path | State sync |
|---|---|---|
| Device online + cloud reachable | App → Cloud MQTT → Device | Device → Cloud MQTT → Backend → WebSocket |
| Device online + no internet | App (on LAN) → Local MQTT → Device | Device → Local MQTT (LAN only). Buffered events sent to cloud when internet restores. |
| Cloud reachable, App not on LAN | App → REST/WS → Backend → Cloud MQTT → Device | Device → Cloud MQTT → Backend → WebSocket |

- Device always connects to **both** local and cloud MQTT brokers when internet available.
- Cloud backend subscribes to device state topics for persistence.
- Local broker handles low-latency LAN commands (phone on same WiFi).
- Device re-syncs full state to cloud on reconnect.

## 3. Device Provisioning Flow

```
User                    App                    Device              Cloud Backend
 │                      │                       │                    │
 │  Open app            │                       │                    │
 ├─────────────────────►│                       │                    │
 │                      │  Enter phone #        │                    │
 │                      ├───────────────────────────────────────────►│  POST /auth/send-otp
 │                      │◄───────────────────────────────────────────┤
 │  Enter OTP           │                       │                    │
 ├─────────────────────►│                       │                    │
 │                      ├───────────────────────────────────────────►│  POST /auth/verify-otp
 │                      │◄───────────────────────────────────────────┤  → JWT tokens
 │                      │                       │                    │
 │  "Put plug in AP"    │                       │                    │
 ├─────────────────────►│                       │                    │
 │                      │  Scan/listen for AP   │                    │
 │                      ├──────────────────────►│                    │
 │                      │◄──────────────────────┤  AP SSID visible   │
 │                      │                       │                    │
 │                      │  Connect to AP        │                    │
 │                      ├──────────────────────►│                    │
 │                      │  Send WiFi creds      │                    │
 │                      ├──────────────────────►│                    │
 │                      │                       │  Connects to WiFi  │
 │                      │                       ├────────────────────►  MQTT CONNECT
 │                      │                       │◄────────────────────  MQTT CONNACK
 │                      │                       │                    │
 │                      │                       │  Publish device    │
 │                      │                       │  info (serial, MAC)│
 │                      │                       ├────────────────────►  /devices/register
 │                      │                       │                    │  → Create device record
 │                      │                       │                    │  (pending household link)
 │                      │  Poll /devices        │                    │
 │                      ├───────────────────────────────────────────►│  GET /devices
 │                      │◄───────────────────────────────────────────┤  → { unlinked: [...] }
 │  Link plug to room   │                       │                    │
 ├─────────────────────►│                       │                    │
 │                      ├───────────────────────────────────────────►│  PATCH /devices/{id}/link
 │                      │◄───────────────────────────────────────────┤  → 200 OK
 │                      │                       │  MQTT: config      │
 │                      │                       │◄────────────────────│
 │  "Setup complete"    │                       │                    │
 ◄──────────────────────┤                       │                    │
```

## 4. MQTT Topic Structure

```
# Device → Cloud
tele/{serial}/state          — current state (power, connectivity, last_changed)
tele/{serial}/online         — birth/last-will
tele/{serial}/event          — event payload (state transitions)

# Cloud → Device
cmnd/{serial}/power          — ON/OFF command

# Backend subscribes
tele/+/state
tele/+/event
tele/+/online

# Backend publishes
cmnd/{serial}/power
```

## 5. Tech decisions

| Concern | Choice |
|---|---|
| API framework | FastAPI (async, auto-docs) |
| Database | PostgreSQL (relational state + time-series events) |
| Cloud MQTT | EMQX (managed) or Mosquitto (self-hosted) |
| Device MQTT | Same broker as cloud, or local Mosquitto (LAN) |
| Auth | JWT (access + refresh tokens), phone OTP via SMS gateway |
| Real-time | WebSocket for web, MQTT + WS for mobile |
