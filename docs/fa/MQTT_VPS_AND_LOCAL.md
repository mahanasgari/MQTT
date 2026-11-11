# MQTT محلی در مقابل VPS

راهنمای انتخاب بروکر MQTT و تست اتصال برای پروژه SmartPlug.

## خلاصه

| حالت | چه زمانی | بروکر | دستور Docker |
|------|----------|-------|--------------|
| **Local** | توسعه روی لپ‌تاپ، تست بدون اینترنت/VPS | Mosquitto در Docker (`localhost:1883`) | `docker compose --profile local-mqtt -f docker-compose.yml -f docker-compose.local-mqtt.yml up -d` |
| **Remote (VPS)** | تست با firmware واقعی، staging، یا تولید | Mosquitto روی سرور (مثلاً `46.31.79.157:1883`) | `docker compose -f docker-compose.yml -f docker-compose.remote-mqtt.yml up -d` |

در حالت **local**، سرویس `api` داخل شبکه Docker به hostname `mosquitto` وصل می‌شود.  
در حالت **remote**، سرویس `mosquitto` Docker اصلاً بالا نمی‌آید و API مستقیم به IP VPS متصل می‌شود.

## حالت Local (Mosquitto در Docker)

### مزایا

- راه‌اندازی یک دستور، بدون VPS
- مناسب توسعه frontend/backend و تست `mosquitto_pub` از میزبان
- اعتبار پیش‌فرض: `smartplug-backend` / `devpass`

### تنظیم `.env`

```env
MQTT_BROKER_HOST=localhost
MQTT_BROKER_PORT=1883
MQTT_USERNAME=smartplug-backend
MQTT_PASSWORD=devpass
```

> **نکته:** داخل کانتینر `api`، override فایل `docker-compose.local-mqtt.yml` مقدار `MQTT_BROKER_HOST=mosquitto` را اعمال می‌کند. مقدار `localhost` در `.env` برای تست از **میزبان** (خارج Docker) است.

### اجرا

```bash
docker compose --profile local-mqtt -f docker-compose.yml -f docker-compose.local-mqtt.yml up -d --build
docker compose exec api alembic upgrade head
```

یا:

```bash
./deploy/scripts/docker-up.sh
```

### تست

```powershell
.\deploy\scripts\mqtt-test.ps1 -Mode local
```

```bash
./deploy/scripts/mqtt-test.sh local
```

معادل دستی:

```bash
mosquitto_pub -h localhost -p 1883 -u smartplug-backend -P devpass \
  -t "tele/SP00000001/state" \
  -m '{"power":"off","connectivity":"online"}'
```

## حالت Remote (VPS)

### مزایا

- firmware دستگاه و backend روی **همان بروکر** کار می‌کنند
- نزدیک به محیط تولید
- چند کلاینت (API، دستگاه‌ها، ابزار تست) از راه دور

### پیش‌نیاز VPS

1. Mosquitto نصب و پیکربندی — [MQTT_SETUP.md](MQTT_SETUP.md)
2. فایروال پورت **1883** باز: `sudo ufw allow 1883/tcp`
3. `include_dir /etc/mosquitto/conf.d` در `mosquitto.conf` فعال باشد (نه local-only mode)
4. کاربر `smartplug-backend` با `mosquitto_passwd` ساخته شده

### تنظیم `.env`

```env
MQTT_BROKER_HOST=46.31.79.157
MQTT_BROKER_PORT=1883
MQTT_USERNAME=smartplug-backend
MQTT_PASSWORD=رمز-واقعی-شما
```

### اجرا

```bash
docker compose -f docker-compose.yml -f docker-compose.remote-mqtt.yml up -d --build
docker compose exec api alembic upgrade head
docker compose restart api
```

فایل `docker-compose.remote-mqtt.yml` سرویس `mosquitto` محلی را غیرفعال می‌کند.

### تست

```powershell
.\deploy\scripts\mqtt-test.ps1 -Mode remote -Serial SP00000001
```

```bash
./deploy/scripts/mqtt-test.sh remote
```

معادل دستی:

```bash
mosquitto_pub -h 46.31.79.157 -p 1883 -u smartplug-backend -P 'رمز-شما' \
  -t "tele/SP00000001/state" \
  -m '{"power":"on","connectivity":"online"}'
```

## مقایسه جریان داده

```
[Local]
  mosquitto_pub (host) → localhost:1883 → Mosquitto (Docker) → API (Docker) → Web

[Remote]
  mosquitto_pub (host) → 46.31.79.157:1883 → Mosquitto (VPS) → API (Docker) → Web
  ESP8266 (firmware)  → 46.31.79.157:1883 → Mosquitto (VPS) → API (Docker) → Web
```

## عیب‌یابی

| علامت | علت محتمل | راه‌حل |
|-------|-----------|--------|
| `Connection refused` روی local | پروفایل `local-mqtt` فعال نیست | دستور compose با `-f docker-compose.local-mqtt.yml` |
| API لاگ «MQTT disconnected» (remote) | IP/رمز اشتباه یا فایروال | `.env` را بررسی کنید؛ `ufw allow 1883` |
| Mosquitto فقط `127.0.0.1:1883` | `include_dir` کامنت شده | [MQTT_SETUP.md](MQTT_SETUP.md) — بخش include_dir |
| publish موفق، داشبورد خالی | سریال در topic با DB یکی نیست | سریال `SP00000001` را ثبت کنید — [START_HERE.md](START_HERE.md) |
| `mosquitto_pub` پیدا نمی‌شود | clients نصب نیست | `apt install mosquitto-clients` یا Docker Desktop |

## مستندات مرتبط

- [START_HERE.md](START_HERE.md) — راهنمای جامع
- [MQTT_SETUP.md](MQTT_SETUP.md) — نصب Mosquitto روی Ubuntu
- [QUICKSTART_DOCKER.md](QUICKSTART_DOCKER.md) — Docker سریع
- [../README.md](../README.md) — فهرست مستندات
