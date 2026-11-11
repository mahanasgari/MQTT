# SmartPlug Documentation

Central index for project guides. **Persian (فارسی)** is the primary locale for day-to-day setup; English guides mirror the same workflows.

## Start here

| Language | Master guide |
|----------|--------------|
| **فارسی (recommended)** | [fa/START_HERE.md](fa/START_HERE.md) |
| **English** | [en/START_HERE.md](en/START_HERE.md) |

Default web locale is **Persian** (`/fa/...`). Set `NEXT_PUBLIC_DEFAULT_LOCALE=fa` in `.env` (already the default).

## Persian guides (`docs/fa/`)

| Guide | Description |
|-------|-------------|
| [START_HERE.md](fa/START_HERE.md) | راهنمای جامع: Docker، ورود، ادمین، ثبت دستگاه، MQTT |
| [VPS_DEPLOY.md](fa/VPS_DEPLOY.md) | استقرار کامل روی VPS (Nginx + MQTT) |
| [MQTT_VPS_AND_LOCAL.md](fa/MQTT_VPS_AND_LOCAL.md) | انتخاب بروکر محلی Docker در مقابل VPS |
| [QUICKSTART_DOCKER.md](fa/QUICKSTART_DOCKER.md) | راه‌اندازی سریع Docker |
| [MQTT_SETUP.md](fa/MQTT_SETUP.md) | پیکربندی Mosquitto روی VPS (include_dir، فایروال) |
| [ADMIN_GUIDE.md](fa/ADMIN_GUIDE.md) | پنل مدیریت پلتفرم |
| [DEPLOYMENT_GUIDE.md](fa/DEPLOYMENT_GUIDE.md) | استقرار تولید |

## English guides (`docs/en/`)

| Guide | Description |
|-------|-------------|
| [START_HERE.md](en/START_HERE.md) | Full setup: Docker profiles, login, admin, devices, MQTT |

## Root-level references (English)

| File | Description |
|------|-------------|
| [../README.md](../README.md) | Project overview, stack, API reference |
| [../QUICKSTART_DOCKER.md](../QUICKSTART_DOCKER.md) | Docker quick start (English, root copy) |
| [../MQTT_SETUP.md](../MQTT_SETUP.md) | Mosquitto production setup |
| [../product_spec.md](../product_spec.md) | Product scope |
| [../architecture.md](../architecture.md) | System architecture |
| [../api_contract.md](../api_contract.md) | REST + MQTT contract |
| [../db_schema.md](../db_schema.md) | Database schema |

## Docker Compose profiles (summary)

| Mode | Command |
|------|---------|
| **Local MQTT** (Mosquitto in Docker) | `docker compose --profile local-mqtt -f docker-compose.yml -f docker-compose.local-mqtt.yml up -d` |
| **Remote MQTT** (VPS broker) | `docker compose -f docker-compose.yml -f docker-compose.remote-mqtt.yml up -d` |

See [fa/MQTT_VPS_AND_LOCAL.md](fa/MQTT_VPS_AND_LOCAL.md) or [en/START_HERE.md](en/START_HERE.md) for details.
