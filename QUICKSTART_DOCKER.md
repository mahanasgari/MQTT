# Quick Start with Docker

Run the full SmartPlug stack locally: **PostgreSQL**, **Mosquitto MQTT**, **FastAPI**, and **Next.js**.

## Prerequisites

- Docker Desktop (or Docker Engine + Compose v2)
- Git

## 1. Configure environment

```bash
cp .env.example .env
```

Default MQTT credentials for dev:

| Setting | Value |
|---------|-------|
| MQTT user | `smartplug-backend` |
| MQTT password | `devpass` |
| API | `http://localhost:8000` |
| Web | `http://localhost:3000` |
| Postgres | `localhost:5433` |

Set `PLATFORM_ADMIN_PHONES` to your phone (E.164) to access `/admin` after login.

## 2. Start the stack

**Linux / macOS:**

```bash
chmod +x deploy/scripts/docker-up.sh
./deploy/scripts/docker-up.sh
```

**Windows (PowerShell):**

```powershell
docker compose up -d --build
docker compose exec api alembic upgrade head
```

## 3. Verify services

```bash
curl http://localhost:8000/health
```

Open http://localhost:3000/en/login (or `/fa/login` for Persian).

## 4. Test MQTT

Publish fake device telemetry (requires [mosquitto-clients](https://mosquitto.org/download/) on your host):

```bash
mosquitto_pub -h localhost -p 1883 -u smartplug-backend -P devpass \
  -t "tele/SP00000001/state" \
  -m '{"power":"off","connectivity":"online"}'
```

Subscribe to commands:

```bash
mosquitto_sub -h localhost -p 1883 -u smartplug-backend -P devpass -t "cmnd/#" -v
```

## 5. Register a device

1. Log in at http://localhost:3000/en/login (`?dev=1` for auto OTP in development)
2. Go to **Devices → Add device**
3. Enter serial `SP00000001`, get pairing token, register, link to household
4. Publish MQTT state again — dashboard should show the device

Or use **Admin** (`/en/admin`) to seed serial and create pairing tokens.

## 6. Stop

```bash
docker compose down
```

Data persists in Docker volumes `pgdata` and `mosquitto_config`.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| API can't connect to DB | Wait for `db` healthcheck; run `docker compose exec api alembic upgrade head` |
| MQTT connection refused | Check `docker compose ps`; Mosquitto creates passwd on first start |
| Web shows wrong API URL | Set `NEXT_PUBLIC_API_URL=http://localhost:8000/v1` in `.env`, rebuild `web` |
| Admin 403 | Add your phone to `PLATFORM_ADMIN_PHONES` in `.env`, restart `api` |

## Persian guide

See [docs/fa/QUICKSTART_DOCKER.md](docs/fa/QUICKSTART_DOCKER.md).

## Related

- [MQTT_SETUP.md](MQTT_SETUP.md) — production Mosquitto on VPS
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) — full production deployment
- [docs/fa/MQTT_SETUP.md](docs/fa/MQTT_SETUP.md) — راهنمای فارسی MQTT
