# AGENTS.md — MQTT-Mobile-WEB

## Stack
- **Backend**: FastAPI (Python 3.11+) + PostgreSQL 15 + MQTT (EMQX/Mosquitto)
- **Frontend**: Next.js 16 (App Router, TypeScript, Tailwind CSS v4)
- **Mobile**: Flutter (Dart, Riverpod + go_router)
- **Device protocol**: MQTT (firmware exists, supports AP-based WiFi setup)
- **Auth**: Phone-number OTP only (no email/password)

## Source of truth
All design decisions are in these 4 files — read them before writing any code:
1. `product_spec.md` — scope, entities, features
2. `architecture.md` — cloud/local hybrid, provisioning flow, system context
3. `api_contract.md` — REST endpoints, MQTT topics, WebSocket
4. `db_schema.md` — tables, columns, indexes, foreign keys

## Key constraints
- Phone-number auth only — no email, no password
- Each device has a local MQTT broker on LAN + cloud MQTT when internet available
- Event sourcing: every state change (ON/OFF, online/offline) is an immutable event
- Device provisioning: AP mode → WiFi creds → MQTT connect → cloud registration → household link
- Share via phone number with permission levels (view/control/admin)

## Port mapping gotcha
Docker Compose maps PostgreSQL to **port 5433** externally (5432 internal). The `.env` default and `DATABASE_URL` use `localhost:5433`. If you see connection errors, check this first.

## Full stack Docker (repo root — recommended for MQTT testing)
```bash
cp .env.example .env
docker compose up -d --build          # db + mosquitto + api + web
docker compose exec api alembic upgrade head
# Or: ./deploy/scripts/docker-up.sh (Linux/macOS)
```
- Web: http://localhost:3000/en/login (or `/fa/login`)
- API: http://localhost:8000
- MQTT: localhost:1883 (`smartplug-backend` / `devpass`)
- Admin panel: `/en/admin` — set `PLATFORM_ADMIN_PHONES` in `.env`
- See [QUICKSTART_DOCKER.md](QUICKSTART_DOCKER.md) and [docs/fa/QUICKSTART_DOCKER.md](docs/fa/QUICKSTART_DOCKER.md)

## Backend commands (from `backend/`)
```bash
pip install -r requirements.txt          # install deps
uvicorn app.main:app --reload            # dev server → http://localhost:8000
alembic upgrade head                     # apply migrations
alembic revision --autogenerate -m "msg" # create migration
docker compose up -d db                  # start PostgreSQL only
docker compose up --build                # full stack (app + postgres)
```

## Frontend commands (from `frontend/`)
```bash
npm install          # install deps
npm run dev          # dev server → http://localhost:3000
npm run lint         # ESLint (TypeScript + Next.js rules)
npm run build        # production build
```

No typecheck script — TypeScript checking happens via `npm run build` (Next.js runs `tsc` internally).

## Mobile commands (from `mobile/`)
```bash
flutter pub get          # install deps
flutter run              # run on connected device/emulator
flutter test             # run tests
```

## Backend gotchas
- `alembic.ini` has port 5432 in `sqlalchemy.url`, but `DATABASE_URL` in `.env` overrides it to 5433. Always use `DATABASE_URL` from `.env`.
- ORM attribute for `device_events.metadata` and `pairing_tokens.metadata` is `payload` (avoids SQLAlchemy reserved name conflict). DB column is still `metadata`.
- MQTT connection is non-fatal at startup — backend logs a warning and continues without MQTT. This is by design for local dev without a broker.
- Dev OTP endpoint `GET /v1/dev/otp/{phone}` only works when `ENVIRONMENT=development` (the default). Set to `production` on deploy.
- OTP codes print to backend terminal. In dev, use `http://localhost:3000/login?dev=1` for auto-fill panel.

## Frontend gotchas
- All routes under `(auth)/` are auth-guarded by `src/app/[locale]/(auth)/layout.tsx`. If you add pages there, they're automatically protected.
- **i18n**: `next-intl` with locales `en` and `fa` — URLs are `/en/...` and `/fa/...` (RTL for Persian).
- Path alias `@/*` maps to `./src/*` (configured in `tsconfig.json`).
- Tailwind CSS v4 uses `@tailwindcss/postcss` PostCSS plugin (not the old `tailwindcss` PostPlugin). Config is in `postcss.config.mjs`.
- API client at `src/lib/api.ts` handles JWT refresh automatically and redirects to `/login` on failure.
- WebSocket connects to `/v1/ws/devices/{id}/state` with JWT via query param `?token=eyJ...`.

## Mobile gotchas
- Uses Riverpod for state management, go_router for navigation.
- **i18n**: `flutter gen-l10n` — ARB files in `lib/l10n/`; locale switcher in home menu.
- `.env` file must exist in `mobile/` root (flutter_dotenv loads it). See `.env.example` for required vars.
- WebSocket channel via `web_socket_channel` package.

## MQTT topic structure
```
# Device → Cloud
tele/{serial}/state      — current state (power, connectivity)
tele/{serial}/online     — birth/LWT (online/offline)
tele/{serial}/event      — event payload (state transitions)

# Cloud → Device
cmnd/{serial}/power      — ON/OFF command
```
Backend subscribes to `tele/+/state`, `tele/+/event`, `tele/+/online`.

## Mosquitto (VPS) setup for production
```bash
# On VPS
sudo ufw allow 1883
sudo mosquitto_passwd -c /etc/mosquitto/passwd smartplug-backend
```
Create `/etc/mosquitto/conf.d/smartplug.conf`:
```
listener 1883 0.0.0.0
allow_anonymous false
password_file /etc/mosquitto/passwd
```
Test: `mosquitto_pub -h your-vps -t "cmnd/SP00000000/power" -m "on"`

## Repo structure
```
/
├── backend/         # FastAPI (app.main:app)
│   ├── app/
│   │   ├── models/          # SQLAlchemy ORM (11 tables)
│   │   ├── schemas/         # Pydantic request/response
│   │   ├── routers/         # auth, devices, households, shares, ws, dev, health
│   │   ├── services/        # auth, mqtt, realtime, access_control, device
│   │   └── utils/           # E.164 phone validation
│   ├── alembic/versions/    # DB migrations
│   └── docker-compose.yml   # PostgreSQL service
├── frontend/        # Next.js (App Router)
│   └── src/
│       ├── app/             # Pages: (auth)/dashboard, (auth)/devices, (auth)/shares, login
│       ├── components/      # DashboardDeviceCard, DeviceCard, HouseholdSelector, Navbar, PowerToggle, StateBadge
│       ├── lib/             # api.ts, auth.tsx, validation.ts, ws.ts
│       └── types/           # index.ts (all TypeScript interfaces)
├── mobile/          # Flutter (Riverpod + go_router)
└── *.md             # Design docs (product_spec, architecture, api_contract, db_schema)
```
