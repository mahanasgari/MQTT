# SmartPlug — IoT Smart Plug Platform

A full-stack IoT smart plug platform with cloud/local hybrid MQTT, phone-number auth, event sourcing, and device provisioning via AP mode.

## Documentation

**Start here (Persian):** [docs/fa/START_HERE.md](docs/fa/START_HERE.md) — full Docker setup, login, admin, device registration, and MQTT testing.

| | |
|---|---|
| **Docs index** | [docs/README.md](docs/README.md) |
| **English setup** | [docs/en/START_HERE.md](docs/en/START_HERE.md) |
| **MQTT local vs VPS** | [docs/fa/MQTT_VPS_AND_LOCAL.md](docs/fa/MQTT_VPS_AND_LOCAL.md) |
| **VPS full deploy** | [docs/fa/VPS_DEPLOY.md](docs/fa/VPS_DEPLOY.md) |

Default web locale is **Persian** (`/fa/...`; `NEXT_PUBLIC_DEFAULT_LOCALE=fa`). Dev login: http://localhost:3000/fa/login?dev=1

### Docker Compose (full stack)

**Local MQTT** (Mosquitto in Docker):

```bash
cp .env.example .env
docker compose --profile local-mqtt -f docker-compose.yml -f docker-compose.local-mqtt.yml up -d --build
docker compose exec api alembic upgrade head
```

**Remote MQTT** (VPS broker, e.g. `46.31.79.157`):

```bash
# Set MQTT_BROKER_HOST in .env first
docker compose -f docker-compose.yml -f docker-compose.remote-mqtt.yml up -d --build
docker compose exec api alembic upgrade head
```

**VPS (whole stack on the server):** see [docs/fa/VPS_DEPLOY.md](docs/fa/VPS_DEPLOY.md) — `docker compose -f docker-compose.prod.yml up -d --build`

See [docs/fa/START_HERE.md](docs/fa/START_HERE.md) for platform admin, device registration, and troubleshooting.

## Stack

| Layer | Technology |
|---|---|
| **Backend** | FastAPI (Python 3.11+, async) + SQLAlchemy 2.0 + PostgreSQL 15 |
| **Frontend** | Next.js 16 (App Router, TypeScript, Tailwind CSS v4) |
| **Mobile** | Flutter (Dart, Riverpod + go_router) |
| **Device protocol** | MQTT (firmware exists with AP-based WiFi setup) |
| **Auth** | Phone-number OTP only (no email/password) |

## Prerequisites

- **Python** 3.11+
- **Node.js** 20+
- **PostgreSQL** 15 (or Docker Desktop)
- **Mosquitto** (optional — for local MQTT testing; production broker runs on VPS)
- **Flutter** 3.16+ (for mobile app)

## Quick Start (manual / non-Docker)

For the recommended **Docker full stack**, use [docs/fa/START_HERE.md](docs/fa/START_HERE.md) instead.

### 1. Clone & enter

```bash
git clone <repo-url> smartplug
cd smartplug
```

### 2. Backend setup

```bash
cd backend

# Create virtual environment
python -m venv venv
venv\Scripts\activate   # Windows
# source venv/bin/activate   # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Configure environment
copy .env.example .env   # Windows
# cp .env.example .env   # macOS/Linux
```

Edit `.env` if needed. Defaults work for local dev.

```bash
# Start PostgreSQL via Docker
docker compose up -d db

# Run migrations
alembic upgrade head

# Start dev server
uvicorn app.main:app --reload
```

API is at `http://localhost:8000/v1`. Swagger docs at `http://localhost:8000/docs`.

### 3. Frontend setup

Open a second terminal:

```bash
cd frontend
npm install
npm run dev
```

Frontend is at `http://localhost:3000`.

### 4. Mobile setup (optional)

```bash
cd mobile

# Install Flutter dependencies
flutter pub get

# Configure environment
copy .env.example .env   # Windows
# cp .env.example .env   # macOS/Linux

# Run on connected device/emulator
flutter run
```

## Using the App

### First Time Setup

1. **Create Account**: Open `http://localhost:3000/login` and enter your phone number in E.164 format (e.g., `+8613800138000`)
2. **Verify OTP**: Enter the 6-digit code (printed in backend terminal or use dev auto-fill)
3. **Create Household**: Click "+ Household" on dashboard to create your first household
4. **Add Device**: See [Device Provisioning](#device-provisioning) below

### Dashboard

The dashboard shows:
- **Device count**: Total, Online, and Households
- **Device cards**: Real-time power state with toggle
- **Recent events**: Latest power on/off and connectivity changes
- **Live indicator**: WebSocket connection status

### Device Control

1. **Toggle Power**: Click the power button on any device card
2. **View Details**: Click a device card to see detailed state
3. **Rename**: Edit device name in the device detail page
4. **View Events**: See full event history with timestamps
5. **Share Access**: Grant other users access to the device

### Sharing

1. **Share a Device**: Go to device → Share Access → Enter phone number
2. **Permission Levels**:
   - `view`: Can see device state only
   - `control`: Can turn device on/off
   - `admin`: Full control + can share with others
3. **Accept/Decline**: Recipients see incoming shares in "Incoming Shares" page
4. **Revoke**: Remove access at any time

### Device Provisioning

1. **Put device in AP mode**: Follow device firmware instructions (usually hold button for 5 seconds)
2. **Connect to device AP**: Your phone connects to the device's WiFi hotspot
3. **Send WiFi credentials**: Enter your home WiFi SSID and password
4. **Device connects**: Device connects to home WiFi and cloud MQTT
5. **Link to household**: Device appears in dashboard → Link to your household

### Development Mode

Add `?dev=1` to login URL for OTP auto-fill panel:
```
http://localhost:3000/login?dev=1
```

## OTP Authentication (Development)

Since no SMS provider is configured, OTP codes are handled in two ways during development:

### Option A: Backend logs (always works)

Every OTP is printed to the backend terminal:

```
2025-06-15T12:00:00+0000 [INFO] app.services.auth_service: OTP for +8613800138000: 483921 (expires in 300s)
```

Type the code manually on the login page.

### Option B: Dev auto-fill panel

1. Open `http://localhost:3000/login?dev=1`
2. Enter a phone number in E.164 format (e.g. `+8613800138000`)
3. Click **Send code**
4. A yellow banner appears: `DEV: OTP auto-filled (483921)` — the code is already entered
5. Click **Verify**

The dev endpoint `GET /v1/dev/otp/{phone}` is only active when `ENVIRONMENT=development`.

## Environment Variables

### Backend (`backend/.env`)

| Variable | Default | Description |
|---|---|---|
| `ENVIRONMENT` | `development` | Set to `production` in production (disables dev OTP endpoint) |
| `DATABASE_URL` | `postgresql+asyncpg://smartplug:smartplug@localhost:5433/smartplug` | PostgreSQL connection string |
| `SECRET_KEY` | `change-me` | JWT signing key — **change in production** |
| `CORS_ORIGINS` | `*` | Comma-separated allowed origins |
| `LOG_LEVEL` | `INFO` | Python log level |
| `MQTT_BROKER_HOST` | `localhost` | Mosquitto server address |
| `MQTT_BROKER_PORT` | `1883` | Mosquitto port |
| `MQTT_USERNAME` | — | MQTT username |
| `MQTT_PASSWORD` | — | MQTT password |
| `OTP_LENGTH` | `6` | Number of digits in OTP |
| `OTP_EXPIRE_SECONDS` | `300` | OTP validity window |
| `OTP_RETRY_AFTER_SECONDS` | `60` | Cooldown between OTP requests |

### Frontend (`frontend/.env.local`)

| Variable | Default | Description |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | `http://localhost:8000/v1` | Backend API base URL |

### Mobile (`mobile/.env`)

| Variable | Default | Description |
|---|---|---|
| `API_BASE_URL` | `http://localhost:8000/v1` | Backend API base URL |

## Project Structure

```
├── backend/
│   ├── app/
│   │   ├── main.py          # FastAPI app, lifespan, MQTT wiring
│   │   ├── config.py         # Pydantic settings from .env
│   │   ├── database.py       # Async engine + session factory
│   │   ├── models/           # SQLAlchemy ORM models (11 tables)
│   │   ├── schemas/          # Pydantic request/response schemas
│   │   ├── routers/          # API endpoints (auth, devices, households, shares, ws, dev)
│   │   ├── services/         # Business logic (auth, mqtt, realtime, access_control)
│   │   └── utils/            # E.164 phone validation
│   ├── alembic/              # Database migrations
│   ├── docker-compose.yml    # PostgreSQL service
│   └── Dockerfile            # Backend container
├── frontend/
│   ├── src/
│   │   ├── app/              # Next.js App Router pages
│   │   ├── components/       # Reusable UI components
│   │   └── lib/              # API client, auth context, WebSocket, validation
│   ├── .env.local
│   └── package.json
├── mobile/
│   ├── lib/
│   │   ├── core/             # Constants, theme, utilities
│   │   ├── data/             # API client, models
│   │   ├── presentation/     # UI pages, widgets
│   │   └── routes/           # GoRouter configuration
│   ├── .env
│   └── pubspec.yaml
├── product_spec.md           # Product scope and entities
├── architecture.md           # System architecture and MQTT design
├── api_contract.md           # Full API documentation
└── db_schema.md              # Database schema details
```

## Production Deployment

### Backend

#### Option A: Docker Compose (full stack)

```bash
cd backend
docker compose up --build -d
```

#### Option B: Manual deployment with systemd + nginx

1. **Build & configure**

```bash
cd backend
python -m venv venv
venv/bin/pip install -r requirements.txt
cp .env.example .env
# Edit .env — set SECRET_KEY, ENVIRONMENT=production, DATABASE_URL, CORS_ORIGINS
```

2. **Run with systemd**

Create `/etc/systemd/system/smartplug.service`:

```ini
[Unit]
Description=SmartPlug API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/smartplug/backend
Environment=PATH=/opt/smartplug/backend/venv/bin
ExecStart=/opt/smartplug/backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now smartplug
```

3. **nginx reverse proxy**

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /v1/ws {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

4. **SSL with Certbot**

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Frontend

```bash
cd frontend
# Edit .env.local — set NEXT_PUBLIC_API_URL to production API
npm run build
```

Serve the `out/` directory with nginx or deploy to Vercel/Cloudflare Pages.

### Mobile

```bash
cd mobile
# Edit .env — set API_BASE_URL to production API
flutter build apk --release
# or
flutter build ios --release
```

### MQTT Broker (VPS Mosquitto)

Create `/etc/mosquitto/conf.d/smartplug.conf`:

```
listener 1883 0.0.0.0
allow_anonymous false
password_file /etc/mosquitto/passwd
```

```bash
sudo mosquitto_passwd -c /etc/mosquitto/passwd smartplug-backend
sudo ufw allow 1883
sudo systemctl restart mosquitto
```

Update `backend/.env` with your VPS IP and credentials.

### Production Checklist

- [ ] **Secret key**: Generate a strong `SECRET_KEY` (`openssl rand -hex 32`)
- [ ] **Environment**: Set `ENVIRONMENT=production`
- [ ] **CORS**: Set `CORS_ORIGINS` to your frontend domain (e.g. `https://app.yourdomain.com`)
- [ ] **Database**: Use a managed PostgreSQL or set up backups
- [ ] **SMS provider**: Integrate Twilio, Vonage, or similar for real OTP delivery
- [ ] **Rate limiting**: Add Redis-based rate limiting to auth endpoints
- [ ] **HTTPS**: Enforce TLS on your domain
- [ ] **MQTT auth**: Set strong username/password for Mosquitto
- [ ] **Logging**: Use a centralized logging service (e.g., Loki, DataDog)

## Architecture Overview

- **Cloud/local hybrid**: Devices connect to both a local LAN broker and the cloud broker (VPS)
- **Event sourcing**: Every state change (ON/OFF, online/offline) is stored as an immutable event
- **Device provisioning**: AP mode → WiFi creds → MQTT connect → cloud registration → household link
- **Real-time updates**: WebSocket endpoint (`/v1/ws`) pushes state changes, events, and connectivity updates
- **Access control**: Household-based roles (admin/member) + share permissions (view/control/admin)

## Troubleshooting

### Database Connection Errors

**Port mismatch**: Docker Compose maps PostgreSQL to port **5433** externally (5432 internal). Ensure `DATABASE_URL` uses `localhost:5433`.

```bash
# Check if PostgreSQL is running
docker compose up -d db
docker compose ps

# Check connection
psql -h localhost -p 5433 -U smartplug -d smartplug
```

### MQTT Connection Issues

**Backend starts without MQTT**: This is normal if no broker is running. The backend logs a warning and continues.

```bash
# Test MQTT broker connection
mosquitto_pub -h localhost -t "test/topic" -m "hello"

# Check backend logs for MQTT connection status
```

### Frontend Build Errors

**Tailwind CSS v4**: Uses `@tailwindcss/postcss` PostCSS plugin (not the old `tailwindcss` PostPlugin). Config is in `postcss.config.mjs`.

```bash
# Clear build cache
rm -rf .next
npm run build
```

### Mobile Build Errors

**Environment file**: `.env` must exist in `mobile/` root. See `.env.example` for required vars.

```bash
# Install Flutter dependencies
flutter pub get

# Check for issues
flutter doctor
```

### Common Issues

| Issue | Solution |
|---|---|
| `401 Unauthorized` | Token expired — refresh or re-login |
| `403 Forbidden` | No permission to access device — check share permissions |
| `404 Not Found` | Device not provisioned or linked |
| `500 Internal Server Error` | Check backend logs for details |
| WebSocket disconnects | Check network, JWT token validity |

## API Reference

Full API documentation: `http://localhost:8000/docs` (Swagger UI)

### Key Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/v1/auth/send-otp` | Send OTP to phone number |
| `POST` | `/v1/auth/verify-otp` | Verify OTP and get tokens |
| `GET` | `/v1/households` | List user's households |
| `POST` | `/v1/households` | Create household |
| `GET` | `/v1/devices` | List devices |
| `PATCH` | `/v1/devices/{id}/control` | Send control command |
| `GET` | `/v1/devices/{id}/events` | Get device events |
| `POST` | `/v1/shares` | Create share |
| `WS` | `/v1/ws/devices/{id}/state` | Real-time state updates |

### MQTT Topics

```
# Device → Cloud
tele/{serial}/state      — current state (power, connectivity)
tele/{serial}/online     — birth/LWT (online/offline)
tele/{serial}/event      — event payload (state transitions)

# Cloud → Device
cmnd/{serial}/power      — ON/OFF command
```

## License

Proprietary — all rights reserved.
