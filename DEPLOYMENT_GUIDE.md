# SmartPlug Production Deployment Guide

Master handbook for deploying the commercial IoT smart plug platform to a Linux VPS. This document is the entry point; deep dives live in companion docs.

## Document map

| Document | Contents |
|----------|----------|
| [MQTT_SETUP.md](MQTT_SETUP.md) | Mosquitto install, auth, ACL, TLS, topics, ESP8266 credentials |
| [DEVICE_REGISTRATION_FLOW.md](DEVICE_REGISTRATION_FLOW.md) | Ownership, serial numbers, API/DB registration, sharing |
| [DEVICE_PROVISIONING_FLOW.md](DEVICE_PROVISIONING_FLOW.md) | First boot, AP mode, WiFi setup, MQTT connect |
| [SERVER_ARCHITECTURE.md](SERVER_ARCHITECTURE.md) | Multi-device model, real-time updates, command flow |
| [api_contract.md](api_contract.md) | Full REST/WebSocket/MQTT API reference |
| [db_schema.md](db_schema.md) | PostgreSQL tables and relationships |
| [architecture.md](architecture.md) | Cloud/local hybrid MQTT design |

## System overview

```
┌──────────────┐      ┌──────────────┐
│ Flutter App  │      │  Next.js Web │
└──────┬───────┘      └──────┬───────┘
       │ HTTPS/WSS           │ HTTPS/WSS
       ▼                     ▼
┌─────────────────────────────────────────┐
│              Linux VPS                   │
│  ┌─────────┐  ┌──────────┐  ┌────────┐ │
│  │  Nginx  │→ │ FastAPI  │→ │ Postgres│ │
│  │  :443   │  │  :8000   │  │  :5432  │ │
│  └─────────┘  └────┬─────┘  └────────┘ │
│                    │ MQTT              │
│              ┌─────▼─────┐             │
│              │ Mosquitto │             │
│              │ :1883/8883│             │
│              └─────┬─────┘             │
└────────────────────┼────────────────────┘
                     │ MQTT (WAN)
              ┌──────▼──────┐
              │ ESP8266 Plug│
              │ (home WiFi) │
              └─────────────┘
```

**Stack:** FastAPI · PostgreSQL 15 · Mosquitto · Nginx · Next.js 16 · Flutter · ESP8266 firmware

## Prerequisites

### VPS

- **OS:** Ubuntu 22.04 LTS or 24.04 LTS (recommended)
- **CPU/RAM:** 2 vCPU, 4 GB RAM minimum for v1 production
- **Disk:** 40 GB SSD (PostgreSQL + logs + Mosquitto persistence)
- **Domain:** e.g. `api.smartplug.example.com`, `app.smartplug.example.com`

### Open ports (UFW)

| Port | Service | Exposure |
|------|---------|----------|
| 22 | SSH | Restrict to admin IPs |
| 80 | HTTP (Certbot redirect) | Public |
| 443 | HTTPS (API + Web + WS) | Public |
| 1883 | MQTT plain | Public (devices) or VPN-only |
| 8883 | MQTT TLS | Public (recommended for production) |
| 5432 | PostgreSQL | **Never public** — localhost or private network only |
| 8000 | Uvicorn | **Never public** — Nginx reverse proxy only |

### Local tooling

- Git, Docker (optional), Python 3.11+, Node.js 20+, Flutter 3.16+ (for mobile builds)
- `mosquitto-clients` for broker smoke tests

## Production folder layout

Recommended layout on the VPS:

```
/opt/smartplug/
├── backend/
│   ├── app/
│   ├── alembic/
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── docker-compose.yml      # dev/small prod (app + db)
│   └── .env                    # secrets — chmod 600
├── frontend/
│   ├── .next/                  # after npm run build
│   └── .env.production.local
├── mobile/                     # source only; APK/IPA built in CI
└── deploy/
    ├── nginx/
    │   ├── api.smartplug.conf
    │   └── app.smartplug.conf
    ├── mosquitto/
    │   ├── smartplug.conf
    │   └── acl
    ├── systemd/
    │   └── smartplug.service
    └── scripts/
        ├── backup-db.sh
        ├── migrate.sh
        ├── seed-serials.sql
        └── insert-pairing-token.sql
```

Clone the repository to `/opt/smartplug` and keep `deploy/` configs in version control (without secrets).

## Environment variables

### Backend (`/opt/smartplug/backend/.env`)

Copy from `backend/.env.example` and set production values:

```bash
# Core
ENVIRONMENT=production
SECRET_KEY=<openssl rand -hex 32>
LOG_LEVEL=INFO

# Database — use internal hostname; Docker maps 5433→5432 externally in dev only
DATABASE_URL=postgresql+asyncpg://smartplug:<strong-password>@127.0.0.1:5432/smartplug

# CORS — comma-separated, no wildcards in production
CORS_ORIGINS=https://app.smartplug.example.com

# MQTT — see MQTT_SETUP.md
MQTT_BROKER_HOST=127.0.0.1
MQTT_BROKER_PORT=1883
MQTT_CLIENT_ID=smartplug-backend-prod
MQTT_USERNAME=smartplug-backend
MQTT_PASSWORD=<strong-mqtt-password>

# OTP (defaults; SMS delivery is not wired — integrate Twilio/Vonage)
OTP_LENGTH=6
OTP_EXPIRE_SECONDS=300
OTP_RETRY_AFTER_SECONDS=60
```

| Variable | Required | Notes |
|----------|----------|-------|
| `ENVIRONMENT` | Yes | Must be `production` to disable `GET /v1/dev/otp/{phone}` |
| `SECRET_KEY` | Yes | JWT signing; rotate with planned token invalidation |
| `DATABASE_URL` | Yes | Async SQLAlchemy URL (`postgresql+asyncpg://...`) |
| `CORS_ORIGINS` | Yes | Frontend origin(s) only |
| `MQTT_BROKER_HOST` | Yes | `127.0.0.1` if Mosquitto on same VPS |
| `MQTT_USERNAME` / `MQTT_PASSWORD` | Yes | Backend broker principal |

### Frontend (`frontend/.env.production.local`)

```bash
NEXT_PUBLIC_API_URL=https://api.smartplug.example.com/v1
```

WebSocket URL is derived from API URL in `frontend/src/lib/ws.ts` (same host, `wss://`, path `/v1/ws`).

### Mobile (`mobile/.env`)

```bash
API_BASE_URL=https://api.smartplug.example.com/v1
```

Rebuild the app after changing; values are baked into release binaries.

## Deployment procedure

### Phase 1 — Base system

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl ufw nginx certbot python3-certbot-nginx \
  postgresql-client mosquitto-clients

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 1883/tcp
sudo ufw allow 8883/tcp
sudo ufw enable
```

Create service user:

```bash
sudo useradd -r -s /bin/false smartplug
sudo mkdir -p /opt/smartplug
sudo chown -R smartplug:smartplug /opt/smartplug
```

### Phase 2 — PostgreSQL

**Option A — Host PostgreSQL (recommended for single VPS)**

```bash
sudo apt install -y postgresql-15
sudo -u postgres psql <<'SQL'
CREATE USER smartplug WITH PASSWORD 'CHANGE_ME_STRONG';
CREATE DATABASE smartplug OWNER smartplug;
GRANT ALL PRIVILEGES ON DATABASE smartplug TO smartplug;
SQL
```

Edit `postgresql.conf` / `pg_hba.conf` so PostgreSQL listens on `127.0.0.1` only.

**Option B — Docker PostgreSQL**

Use `backend/docker-compose.yml` `db` service. In production, **do not** publish port 5433 publicly; bind to `127.0.0.1:5433:5432` only.

**Option C — Managed PostgreSQL**

Use provider connection string in `DATABASE_URL`. Enable SSL if required by provider.

### Phase 3 — Database migrations

```bash
cd /opt/smartplug/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# Edit .env with production values

alembic upgrade head
```

Verify:

```bash
psql "$DATABASE_URL" -c "\dt"   # adjust URL for psql format if needed
```

### Phase 4 — Mosquitto

Follow [MQTT_SETUP.md](MQTT_SETUP.md) completely before starting the backend.

Minimum smoke test after Mosquitto is running:

```bash
mosquitto_pub -h 127.0.0.1 -u smartplug-backend -P '<password>' \
  -t 'cmnd/TEST_SERIAL/power' -m 'on'
```

### Phase 5 — FastAPI backend

**Option A — systemd (recommended)**

Create `/etc/systemd/system/smartplug.service`:

```ini
[Unit]
Description=SmartPlug FastAPI API
After=network.target postgresql.service mosquitto.service
Wants=postgresql.service mosquitto.service

[Service]
Type=simple
User=smartplug
Group=smartplug
WorkingDirectory=/opt/smartplug/backend
EnvironmentFile=/opt/smartplug/backend/.env
Environment=PATH=/opt/smartplug/backend/venv/bin
ExecStart=/opt/smartplug/backend/venv/bin/uvicorn app.main:app \
  --host 127.0.0.1 --port 8000 --workers 2
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now smartplug
sudo systemctl status smartplug
curl -s http://127.0.0.1:8000/health
```

**Option B — Docker**

Build from `backend/Dockerfile` (no `--reload`):

```bash
cd /opt/smartplug/backend
docker build -t smartplug-api:latest .
docker run -d --name smartplug-api \
  --env-file .env \
  --network host \
  smartplug-api:latest
```

`--network host` simplifies MQTT/DB on localhost; alternatively use a Docker network with explicit service names.

**MQTT at startup:** If the broker is unreachable, the API logs a warning and continues (by design). Fix broker connectivity before going live.

### Phase 6 — Nginx reverse proxy

**API** — `/etc/nginx/sites-available/api.smartplug.conf`:

```nginx
upstream smartplug_api {
    server 127.0.0.1:8000;
    keepalive 32;
}

server {
    listen 80;
    server_name api.smartplug.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.smartplug.example.com;

    ssl_certificate     /etc/letsencrypt/live/api.smartplug.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.smartplug.example.com/privkey.pem;

    client_max_body_size 1m;

    location / {
        proxy_pass http://smartplug_api;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
    }

    location /v1/ws {
        proxy_pass http://smartplug_api;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }
}
```

**Web app** — separate `server` block for `app.smartplug.example.com` proxying to Next.js (`localhost:3000`) or serving static `out/` if exported.

```bash
sudo ln -s /etc/nginx/sites-available/api.smartplug.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d api.smartplug.example.com -d app.smartplug.example.com
```

### Phase 7 — Next.js frontend

```bash
cd /opt/smartplug/frontend
npm ci
echo "NEXT_PUBLIC_API_URL=https://api.smartplug.example.com/v1" > .env.production.local
npm run build
```

Run with PM2 or systemd:

```bash
npm run start   # listens :3000 by default
```

Or deploy to Vercel/Cloudflare Pages with the same `NEXT_PUBLIC_API_URL`.

### Phase 8 — Flutter mobile

```bash
cd /opt/smartplug/mobile
cp .env.example .env
# Set API_BASE_URL=https://api.smartplug.example.com/v1

flutter pub get
flutter build apk --release
# flutter build ios --release  (on macOS with signing)
```

Distribute APK/AAB via Play Store or enterprise MDM. MQTT broker hostname for **devices** is configured in firmware, not the mobile app.

## Docker deployment strategy

| Environment | Compose | Notes |
|-------------|---------|-------|
| **Full local stack** | **`docker-compose.yml` (repo root)** | **Postgres + Mosquitto + API + Web; see [QUICKSTART_DOCKER.md](QUICKSTART_DOCKER.md)** |
| Local dev (API only) | `backend/docker-compose.yml` | App + Postgres; port 5433; `--reload` |
| Production single VPS | App container + Postgres container; Mosquitto + Nginx on host | Simplest ops model |
| Production scaled | Managed Postgres + multiple API replicas + Redis for WS | Future; see SERVER_ARCHITECTURE.md |

Persian deployment guides: `docs/fa/` (QUICKSTART_DOCKER, MQTT_SETUP, DEPLOYMENT_GUIDE, ADMIN_GUIDE).

Example production compose overlay (document only — add to `deploy/docker-compose.prod.yml` if desired):

```yaml
services:
  app:
    build: ../backend
    restart: always
    env_file: ../backend/.env
    ports:
      - "127.0.0.1:8000:8000"
    depends_on:
      db:
        condition: service_healthy
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 2

  db:
    image: postgres:15-alpine
    restart: always
    environment:
      POSTGRES_USER: smartplug
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: smartplug
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U smartplug"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

Mosquitto remains on the host (or a dedicated broker VM) for device-facing port 1883/8883.

## Production checklist

### Security

- [ ] `SECRET_KEY` generated with `openssl rand -hex 32`
- [ ] `ENVIRONMENT=production` (disables dev OTP endpoint)
- [ ] `CORS_ORIGINS` set to real frontend domain(s) only
- [ ] PostgreSQL not exposed to the internet
- [ ] Uvicorn bound to `127.0.0.1` behind Nginx
- [ ] TLS on API and web (Let's Encrypt or commercial cert)
- [ ] Mosquitto `allow_anonymous false` + ACL file
- [ ] Strong MQTT passwords for backend and per-device principals
- [ ] SSH key-only auth; disable root login
- [ ] `.env` file mode `600`, owned by `smartplug`

### Reliability

- [ ] `systemctl enable smartplug postgresql mosquitto nginx`
- [ ] PostgreSQL daily backups (`deploy/scripts/backup-db.sh`)
- [ ] Log rotation (`/var/log/nginx/`, journald limits)
- [ ] Health check monitoring on `GET /health`
- [ ] Disk space alerts

### Application

- [ ] `alembic upgrade head` applied
- [ ] SMS/OTP provider integrated (currently OTP logs to stdout in dev)
- [ ] Factory serial import procedure documented ([DEVICE_REGISTRATION_FLOW.md](DEVICE_REGISTRATION_FLOW.md))
- [ ] Pairing token bootstrap procedure for new devices (ops script)
- [ ] Firmware MQTT broker hostname points to production VPS
- [ ] Mobile and web `API_BASE_URL` / `NEXT_PUBLIC_API_URL` verified

### MQTT

- [ ] Backend subscribes to `tele/+/state`, `tele/+/event`, `tele/+/online`
- [ ] Test publish `cmnd/{serial}/power` end-to-end with a real device
- [ ] LWT/retained `tele/{serial}/online` verified

## Operational runbooks

### Deploy new API version

```bash
cd /opt/smartplug
git pull origin main
cd backend && source venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
sudo systemctl restart smartplug
curl -s https://api.smartplug.example.com/health
```

### Rollback API

```bash
git checkout <previous-tag>
sudo systemctl restart smartplug
# Only downgrade DB if migration is reversible
```

### Database backup

```bash
#!/bin/bash
# deploy/scripts/backup-db.sh
STAMP=$(date +%Y%m%d_%H%M%S)
pg_dump -h 127.0.0.1 -U smartplug smartplug | gzip > /var/backups/smartplug_$STAMP.sql.gz
find /var/backups -name 'smartplug_*.sql.gz' -mtime +14 -delete
```

### MQTT certificate rotation

1. Obtain new certs (Let's Encrypt or internal CA)
2. Update `/etc/mosquitto/certs/`
3. `sudo systemctl reload mosquitto`
4. OTA firmware CA update if device pins change (firmware OTA not in v1 scope)

### Incident: devices show offline

1. Check Mosquitto: `sudo systemctl status mosquitto`
2. Check backend MQTT logs: `journalctl -u smartplug -f`
3. Verify device serial exists in `devices` table
4. Test ACL: `mosquitto_sub -h <vps> -u smartplug-backend -P '...' -t 'tele/+/online'`

## Known implementation gaps (read before go-live)

These are **documented limitations** in the current codebase:

1. **Factory serial whitelist:** Optional strict mode via `REQUIRE_PREREGISTERED_SERIAL=true` — rejects registration when no `devices` row exists for the serial. There is still no `device_inventory` table; factory must pre-seed via SQL/import. See [DEVICE_REGISTRATION_FLOW.md](DEVICE_REGISTRATION_FLOW.md).

2. **MQTT ignores unknown serials:** Telemetry is dropped until `devices.serial` exists. Register before expecting cloud state.

3. **SMS OTP:** OTP codes log to the backend console in development; production requires an SMS gateway integration in `auth_service.py`.

**Recently addressed (no longer gaps):** Pre-provision pairing token API (`POST /v1/devices/pairing-token`), WebSocket realtime queue fix, mobile AP HTTP configure flow, web add-device flow, and in-app usage guides.

## Related reading

- [MQTT_SETUP.md](MQTT_SETUP.md) — broker hardening
- [DEVICE_PROVISIONING_FLOW.md](DEVICE_PROVISIONING_FLOW.md) — customer first-time setup
- [DEVICE_REGISTRATION_FLOW.md](DEVICE_REGISTRATION_FLOW.md) — ownership and sharing
- [SERVER_ARCHITECTURE.md](SERVER_ARCHITECTURE.md) — multi-device and command path
