# Start Here — SmartPlug Setup Guide

Complete guide for running the SmartPlug platform locally: Docker, login, admin panel, device registration, and MQTT testing.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine + Compose v2)
- Git
- Optional: [mosquitto-clients](https://mosquitto.org/download/) for host-side MQTT tests

## 1. Environment setup

```bash
cp .env.example .env
```

Default dev values:

| Setting | Value |
|---------|-------|
| API | `http://localhost:8000` |
| Web (Persian default) | `http://localhost:3000/fa/login` |
| Web (English) | `http://localhost:3000/en/login` |
| Postgres | `localhost:5433` |
| MQTT user | `smartplug-backend` |
| MQTT password | `devpass` |
| Default UI locale | `fa` (`NEXT_PUBLIC_DEFAULT_LOCALE=fa`) |

## 2. Choose MQTT mode

### Option A — Local MQTT (Mosquitto in Docker)

Best for laptop development without a VPS:

```bash
docker compose --profile local-mqtt -f docker-compose.yml -f docker-compose.local-mqtt.yml up -d --build
docker compose exec api alembic upgrade head
```

**Linux/macOS shortcut:**

```bash
chmod +x deploy/scripts/docker-up.sh
./deploy/scripts/docker-up.sh
```

### Option B — Remote MQTT (VPS broker)

Connect the API to Mosquitto on your server (e.g. `46.31.79.157`):

1. Set in `.env`:

```env
MQTT_BROKER_HOST=46.31.79.157
MQTT_BROKER_PORT=1883
MQTT_USERNAME=smartplug-backend
MQTT_PASSWORD=your-mqtt-password
```

2. Start without the local Mosquitto profile:

```bash
docker compose -f docker-compose.yml -f docker-compose.remote-mqtt.yml up -d --build
docker compose exec api alembic upgrade head
```

See [../fa/MQTT_VPS_AND_LOCAL.md](../fa/MQTT_VPS_AND_LOCAL.md) (Persian) or root [MQTT_SETUP.md](../../MQTT_SETUP.md) for VPS Mosquitto setup.

## 3. Health check

```bash
curl http://localhost:8000/health
docker compose ps
```

Open **http://localhost:3000/fa/login?dev=1** (Persian) or `/en/login?dev=1` (English).

The `?dev=1` flag auto-fills OTP when `ENVIRONMENT=development`.

## 4. Login and platform admin

### OTP login

1. Go to http://localhost:3000/fa/login?dev=1
2. Enter phone in E.164 format (e.g. `+989121234567`)
3. Click **Send code** — OTP appears in the yellow banner or API logs
4. Click **Verify**

### Platform admin (`PLATFORM_ADMIN_PHONES`)

1. Add your phone to `.env`:

```env
PLATFORM_ADMIN_PHONES=+989121234567
```

2. Restart API:

```bash
docker compose restart api
```

3. After login, open http://localhost:3000/fa/admin (or `/en/admin`)

See [../fa/ADMIN_GUIDE.md](../fa/ADMIN_GUIDE.md) for the full admin panel guide.

## 5. Register a device

**Fastest (no hardware):** Dashboard → **Local test device**. Creates a virtual plug that stays online; the power toggle works immediately. On the device page use **Simulate online / offline**.

**User flow:** Devices → Add device → serial `SP00000001` → pairing token → link to household.

**Admin flow:** Admin → Devices → register factory serial → create pairing token.

**Deploy the whole stack on a VPS:** [../fa/VPS_DEPLOY.md](../fa/VPS_DEPLOY.md) (`docker-compose.prod.yml`).

## 6. MQTT test

### Topics

```
# Device → Cloud
tele/{serial}/state      — current state (power, connectivity)
tele/{serial}/online     — online/offline (birth/LWT)
tele/{serial}/event      — state transition events

# Cloud → Device
cmnd/{serial}/power      — ON/OFF command
```

### Publish test state (local)

```bash
mosquitto_pub -h localhost -p 1883 -u smartplug-backend -P devpass \
  -t "tele/SP00000001/state" \
  -m '{"power":"off","connectivity":"online"}'
```

### Publish to VPS

```bash
mosquitto_pub -h 46.31.79.157 -p 1883 -u smartplug-backend -P 'your-password' \
  -t "tele/SP00000001/state" \
  -m '{"power":"on","connectivity":"online"}'
```

### Listen for commands

```bash
mosquitto_sub -h localhost -p 1883 -u smartplug-backend -P devpass -t "cmnd/#" -v
```

### Test scripts

```powershell
.\deploy\scripts\mqtt-test.ps1 -Mode local
.\deploy\scripts\mqtt-test.ps1 -Mode remote -Serial SP00000001
```

```bash
./deploy/scripts/mqtt-test.sh local
./deploy/scripts/mqtt-test.sh remote
```

The dashboard should show the device after publish (REST + WebSocket).

## 7. Stop

```bash
docker compose down
```

Data persists in Docker volumes. Use `docker compose down -v` to wipe volumes.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| API cannot reach DB | Postgres is on port **5433**; run `docker compose exec api alembic upgrade head` |
| MQTT refused (local) | Ensure `local-mqtt` profile; check `docker compose ps` for healthy `mosquitto` |
| MQTT refused (VPS) | Open firewall port **1883**: `sudo ufw allow 1883/tcp` — see [MQTT_SETUP.md](../../MQTT_SETUP.md) |
| Mosquitto listens on 127.0.0.1 only | Uncomment `include_dir /etc/mosquitto/conf.d` in `mosquitto.conf` |
| Admin 403 | Phone in `PLATFORM_ADMIN_PHONES` (E.164), then `docker compose restart api` |
| Wrong API in web | Fix `NEXT_PUBLIC_API_URL` in `.env`, rebuild `web` service |

## Related docs

- [../README.md](../README.md) — documentation index
- [../fa/START_HERE.md](../fa/START_HERE.md) — Persian master guide
- [../fa/QUICKSTART_DOCKER.md](../fa/QUICKSTART_DOCKER.md) — Docker quick start (Persian)
- [../../QUICKSTART_DOCKER.md](../../QUICKSTART_DOCKER.md) — Docker quick start (English, root)
- [../../MQTT_SETUP.md](../../MQTT_SETUP.md) — Mosquitto production setup
