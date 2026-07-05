# MQTT Server Setup (Mosquitto)

Production guide for the SmartPlug cloud MQTT broker. Devices (ESP8266) and the FastAPI backend communicate through Mosquitto using the topic layout defined in [api_contract.md](api_contract.md).

## Role in the system

| Component | MQTT role |
|-----------|-----------|
| ESP8266 smart plug | Publishes telemetry; subscribes to commands |
| FastAPI backend | Subscribes to telemetry; publishes commands |
| Mobile / Web apps | **Do not** connect to MQTT directly — use REST + WebSocket |

Backend implementation: `backend/app/services/mqtt_service.py`

## Install Mosquitto on Ubuntu

```bash
sudo apt update
sudo apt install -y mosquitto mosquitto-clients
sudo systemctl enable mosquitto
```

Verify:

```bash
mosquitto -h   # version info
sudo systemctl status mosquitto
```

Log locations:

- `/var/log/mosquitto/mosquitto.log`
- `journalctl -u mosquitto -f`

## Production configuration

Create `/etc/mosquitto/conf.d/smartplug.conf`:

```conf
# --- SmartPlug production broker ---

per_listener_settings true

# Plain MQTT (devices on WAN — migrate to 8883 when firmware supports TLS)
listener 1883 0.0.0.0
protocol mqtt
allow_anonymous false
password_file /etc/mosquitto/passwd
acl_file /etc/mosquitto/acl

# TLS MQTT (recommended for production)
listener 8883 0.0.0.0
protocol mqtt
allow_anonymous false
password_file /etc/mosquitto/passwd
acl_file /etc/mosquitto/acl
cafile /etc/mosquitto/certs/ca.crt
certfile /etc/mosquitto/certs/server.crt
keyfile /etc/mosquitto/certs/server.key
tls_version tlsv1.2

# Persistence
persistence true
persistence_location /var/lib/mosquitto/
autosave_interval 300

# Limits
max_connections 1000
message_size_limit 65536
max_queued_messages 1000

# Logging
log_dest file /var/log/mosquitto/mosquitto.log
log_type error
log_type warning
log_type notice
log_type information
connection_messages true
```

Disable the default anonymous listener if present — check `/etc/mosquitto/mosquitto.conf` for conflicting `listener` directives.

```bash
sudo systemctl restart mosquitto
```

## Username and password setup

### Backend service account

```bash
sudo mosquitto_passwd -c /etc/mosquitto/passwd smartplug-backend
# Enter a strong password; store in backend/.env as MQTT_PASSWORD
```

Add more users **without** `-c` (which overwrites the file):

```bash
sudo mosquitto_passwd /etc/mosquitto/passwd smartplug-monitor
```

### Device credentials (commercial recommendation)

**Pattern A — per-device user (recommended)**

One Mosquitto user per factory serial:

```bash
SERIAL="SN-2026-000001"
sudo mosquitto_passwd /etc/mosquitto/passwd "device-${SERIAL}"
```

Firmware stores `device-SN-2026-000001` + unique password in NVS.

**Pattern B — shared device user with ACL**

Single user `smartplug-devices` with ACL restricting topics per connection is **not** supported natively by Mosquitto (ACL is per username, not per connection). Use Pattern A for isolation.

### Password file permissions

```bash
sudo chown root:mosquitto /etc/mosquitto/passwd
sudo chmod 640 /etc/mosquitto/passwd
```

## Access control (ACL)

Create `/etc/mosquitto/acl`:

```conf
# Backend — full telemetry read, command write
user smartplug-backend
topic read tele/#
topic write cmnd/#
topic write config/#

# Read-only monitoring (optional)
user smartplug-monitor
topic read tele/#
topic read $SYS/#

# Per-device example — serial must match firmware exactly
user device-SN-2026-000001
topic write tele/SN-2026-000001/#
topic read cmnd/SN-2026-000001/#
topic read config/SN-2026-000001

# Repeat block for each device user, OR generate via factory script
```

**Critical rule:** The `{serial}` segment in topics must **exactly match** the string burned into firmware and stored in `devices.serial`. Both formats are valid in this project:

- Commercial: `SN-2026-000001`
- Legacy examples: `SP123456789`

Mixing formats between DB and MQTT breaks routing.

Regenerate ACL when shipping new devices:

```bash
# deploy/scripts/generate-mqtt-acl.sh (example)
for serial in $(cut -d, -f1 /opt/smartplug/factory/serials.csv); do
  echo "user device-${serial}"
  echo "topic write tele/${serial}/#"
  echo "topic read cmnd/${serial}/#"
  echo "topic read config/${serial}"
done | sudo tee -a /etc/mosquitto/acl
sudo systemctl reload mosquitto
```

## TLS support

### Planning

| Port | Use |
|------|-----|
| 1883 | Plain MQTT — acceptable for initial rollout; firewall restrict if possible |
| 8883 | TLS — **target for production** |

### Option 1 — Let's Encrypt (VPS has public DNS)

MQTT TLS often uses a **dedicated broker hostname** (e.g. `mqtt.smartplug.example.com`). Certbot standalone or DNS challenge:

```bash
sudo mkdir -p /etc/mosquitto/certs
sudo certbot certonly --standalone -d mqtt.smartplug.example.com
sudo cp /etc/letsencrypt/live/mqtt.smartplug.example.com/fullchain.pem /etc/mosquitto/certs/server.crt
sudo cp /etc/letsencrypt/live/mqtt.smartplug.example.com/privkey.pem /etc/mosquitto/certs/server.key
sudo chown -R mosquitto:mosquitto /etc/mosquitto/certs
```

Embed Let's Encrypt ISRG Root X1 in ESP8266 firmware for verification.

### Option 2 — Internal CA

For factory flashing, issue a long-lived CA, sign server cert, embed CA cert in all devices.

### Firmware TLS checklist

- [ ] Broker hostname resolves to VPS IP
- [ ] Port 8883 open in UFW
- [ ] CA certificate in firmware trust store
- [ ] SNI hostname matches certificate CN/SAN
- [ ] Reconnect with exponential backoff on disconnect

## Topic naming conventions (production)

### Device → Cloud (ESP publishes, backend subscribes)

| Topic | QoS | Retained | Payload |
|-------|-----|----------|---------|
| `tele/{serial}/state` | 1 | No | `{"power":"on\|off","connectivity":"online\|offline","last_changed_at":"ISO8601"}` |
| `tele/{serial}/event` | 1 | No | `{"type":"power_on\|...","occurred_at":"ISO8601",...}` |
| `tele/{serial}/online` | 1 | **Yes** (birth) | `{"status":"online","ip":"...","mac":"...","firmware_version":"..."}` |

**Last Will and Testament (LWT):** Configure on connect:

- Topic: `tele/{serial}/online`
- Payload: `{"status":"offline"}`
- QoS: 1, Retain: true

Backend treats empty retained message or explicit offline status as `device_offline` ([api_contract.md](api_contract.md) §7).

### Cloud → Device (backend publishes, ESP subscribes)

| Topic | QoS | Payload |
|-------|-----|---------|
| `cmnd/{serial}/power` | 1 | `on` or `off` (plain string) |

Future: `config/{serial}` with JSON `{"interval":60,"broker":"..."}`.

### Backend wildcard subscriptions

On connect, `mqtt_service.py` subscribes:

```
tele/+/state
tele/+/event
tele/+/online
```

Unknown serials: message logged and **skipped** until `devices` row exists ([device_service.py](backend/app/services/device_service.py)).

## ESP8266 authentication with MQTT

### Connect parameters

```
Broker:  mqtt.smartplug.example.com  (or VPS IP for lab)
Port:    8883 (TLS) or 1883 (plain)
Client ID: smartplug-{serial}        (must be unique per broker)
Username: device-{serial}            (Pattern A)
Password: <per-device secret from factory>
Clean session: false                 (optional — enables session persistence)
Keepalive: 60 seconds
```

### On connect sequence (firmware)

1. Connect with credentials + LWT on `tele/{serial}/online`
2. Publish retained birth message to `tele/{serial}/online`
3. Publish current state to `tele/{serial}/state`
4. Subscribe to `cmnd/{serial}/power` (QoS 1)
5. On relay change, publish `tele/{serial}/state` and `tele/{serial}/event`

### On command received

```
Topic: cmnd/SN-2026-000001/power
Payload: on
→ Energize relay
→ Publish tele/SN-2026-000001/state {"power":"on",...}
→ Publish tele/SN-2026-000001/event {"type":"power_on",...}
```

### Local-only / hybrid mode

Per [architecture.md](architecture.md), devices may also connect to a **LAN Mosquitto** instance. Same topic layout; cloud broker is used when internet is available. Local broker can run without auth on isolated LAN (not recommended for production retail).

## Backend wiring

Set in `backend/.env`:

```bash
MQTT_BROKER_HOST=127.0.0.1
MQTT_BROKER_PORT=1883
MQTT_CLIENT_ID=smartplug-backend-prod
MQTT_USERNAME=smartplug-backend
MQTT_PASSWORD=<password from mosquitto_passwd>
```

`MQTTService` in `mqtt_service.py`:

- Sets auth via `set_auth_credentials` when `MQTT_USERNAME` is non-empty
- Publishes commands: `cmnd/{serial}/{command}` with payload value string
- Processes inbound messages in `_on_message` → `handle_state_message` / `handle_event_message` / `handle_availability_message`

## Smoke tests

### From VPS (backend credentials)

```bash
# Subscribe to all telemetry
mosquitto_sub -h 127.0.0.1 -u smartplug-backend -P 'BACKEND_PASS' \
  -t 'tele/+/state' -v

# Simulate device state (use a registered serial)
mosquitto_pub -h 127.0.0.1 -u device-SN-2026-000001 -P 'DEVICE_PASS' \
  -t 'tele/SN-2026-000001/state' \
  -m '{"power":"off","connectivity":"online","last_changed_at":"2026-06-29T12:00:00Z"}'

# Send command
mosquitto_pub -h 127.0.0.1 -u smartplug-backend -P 'BACKEND_PASS' \
  -t 'cmnd/SN-2026-000001/power' -m 'on'
```

### From external network (device perspective)

```bash
mosquitto_pub -h mqtt.smartplug.example.com -p 8883 \
  --cafile ca.crt \
  -u device-SN-2026-000001 -P 'DEVICE_PASS' \
  -t 'tele/SN-2026-000001/online' \
  -m '{"status":"online","ip":"192.168.1.10","mac":"AA:BB:CC:DD:EE:FF"}' -r
```

## Security hardening

### Firewall (UFW)

```bash
sudo ufw allow 1883/tcp comment 'MQTT plain'
sudo ufw allow 8883/tcp comment 'MQTT TLS'
# Do NOT expose 1883 if all firmware uses TLS on 8883
```

Restrict 1883 to known IP ranges if using split plain/TLS rollout.

### Additional measures

- Disable anonymous access globally
- Rotate device passwords on ownership transfer (future feature)
- Monitor `$SYS/broker/clients/connected` for anomaly detection
- Rate-limit connection attempts via fail2ban on auth failures (optional)
- Bind plain listener to private interface only during migration:

  ```conf
  listener 1883 10.0.0.5
  ```

- Never commit `passwd` or device secrets to git

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| Backend log: "MQTT broker not reachable" | Mosquitto down or wrong host/port | `systemctl status mosquitto`; check `.env` |
| Device connects but no state in app | Serial not in `devices` table | Register device first |
| ACL denial in mosquitto.log | Wrong user or topic typo | Match serial exactly in ACL |
| Commands not received on device | Device not subscribed to `cmnd/{serial}/power` | Fix firmware subscription |
| Duplicate client disconnects | Two devices same client ID | Unique `smartplug-{serial}` per device |

## Related documents

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) — VPS deployment order
- [DEVICE_PROVISIONING_FLOW.md](DEVICE_PROVISIONING_FLOW.md) — when device first connects
- [SERVER_ARCHITECTURE.md](SERVER_ARCHITECTURE.md) — command flow through MQTT
