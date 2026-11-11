# از اینجا شروع کنید — راهنمای جامع SmartPlug

راهنمای یک‌جا برای راه‌اندازی کامل پلتفرم اسمارت‌پلاگ: Docker، ورود، پنل ادمین، ثبت دستگاه و تست MQTT.

## پیش‌نیازها

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (یا Docker Engine + Compose v2)
- Git
- اختیاری: [mosquitto-clients](https://mosquitto.org/download/) برای تست MQTT از میزبان

## ۱. تنظیم محیط

```bash
cp .env.example .env
```

مقادیر پیش‌فرض توسعه:

| تنظیم | مقدار |
|-------|-------|
| API | `http://localhost:8000` |
| وب (فارسی) | `http://localhost:3000/fa/login` |
| Postgres | `localhost:5433` |
| کاربر MQTT | `smartplug-backend` |
| رمز MQTT | `devpass` |
| زبان پیش‌فرض UI | `fa` (`NEXT_PUBLIC_DEFAULT_LOCALE=fa`) |

### حالت MQTT: محلی یا VPS

دو پروفایل Docker دارید — یکی را انتخاب کنید:

#### الف) MQTT محلی (Mosquitto داخل Docker)

برای توسعه روی لپ‌تاپ، بدون نیاز به VPS:

```bash
docker compose --profile local-mqtt -f docker-compose.yml -f docker-compose.local-mqtt.yml up -d --build
docker compose exec api alembic upgrade head
```

**لینوکس / مک:** اسکریپت آماده:

```bash
chmod +x deploy/scripts/docker-up.sh
./deploy/scripts/docker-up.sh
```

#### ب) MQTT روی VPS (بروکر از راه دور)

برای اتصال API به Mosquitto روی سرور (مثلاً `46.31.79.157`):

1. در `.env` تنظیم کنید:

```env
MQTT_BROKER_HOST=46.31.79.157
MQTT_BROKER_PORT=1883
MQTT_USERNAME=smartplug-backend
MQTT_PASSWORD=رمز-شما
```

2. سرویس‌ها را بدون پروفایل `local-mqtt` بالا بیاورید:

```bash
docker compose -f docker-compose.yml -f docker-compose.remote-mqtt.yml up -d --build
docker compose exec api alembic upgrade head
```

جزئیات بیشتر: [MQTT_VPS_AND_LOCAL.md](MQTT_VPS_AND_LOCAL.md) و [MQTT_SETUP.md](MQTT_SETUP.md).

## ۲. بررسی سلامت

```bash
curl http://localhost:8000/health
docker compose ps
```

مرورگر: **http://localhost:3000/fa/login?dev=1**

پارامتر `?dev=1` در حالت توسعه (`ENVIRONMENT=development`) OTP را خودکار پر می‌کند.

## ۳. ورود و دسترسی ادمین

### ورود با OTP

1. به http://localhost:3000/fa/login?dev=1 بروید
2. شماره موبایل E.164 وارد کنید (مثلاً `+989121234567`)
3. **ارسال کد** — کد در بنر زرد یا لاگ API چاپ می‌شود
4. **تأیید** — وارد داشبورد می‌شوید

### پنل مدیریت پلتفرم (`PLATFORM_ADMIN_PHONES`)

برای دسترسی به `/fa/admin`:

1. شماره خود را در `.env` قرار دهید:

```env
PLATFORM_ADMIN_PHONES=+989121234567
```

2. سرویس API را ری‌استارت کنید:

```bash
docker compose restart api
```

3. پس از ورود OTP، لینک **مدیریت** در نوار بالا ظاهر می‌شود یا مستقیم بروید به http://localhost:3000/fa/admin

راهنمای کامل: [ADMIN_GUIDE.md](ADMIN_GUIDE.md)

## ۴. ثبت دستگاه

### روش سریع — دستگاه آزمایشی محلی (بدون سخت‌افزار)

در داشبورد دکمه **دستگاه آزمایشی محلی** را بزنید. یک پریز مجازی ساخته می‌شود، آنلاین می‌شود و کلید روشن/خاموش کار می‌کند.

در صفحه دستگاه دکمه‌های **شبیه‌سازی آنلاین / آفلاین** هم هست.

### روش الف — از پنل کاربر (سریال واقعی)

1. ورود در http://localhost:3000/fa/login?dev=1
2. **دستگاه‌ها → افزودن دستگاه** (یا همان دکمه آزمایشی محلی)
3. سریال مثلاً `SP00000001`، دریافت توکن جفت‌سازی
4. ثبت و اتصال به خانه (household)

1. ورود در http://localhost:3000/fa/login?dev=1
2. **دستگاه‌ها → افزودن دستگاه**
3. سریال مثلاً `SP00000001`، دریافت توکن جفت‌سازی
4. ثبت و اتصال به خانه (household)

### روش ب — از پنل ادمین

1. **مدیریت → دستگاه‌ها**
2. ثبت سریال کارخانه (اگر `REQUIRE_PREREGISTERED_SERIAL=true`)
3. **ایجاد توکن** و دادن به مشتری

## ۵. تست MQTT

### ساختار topicها

```
# دستگاه → ابر
tele/{serial}/state      — وضعیت فعلی (power, connectivity)
tele/{serial}/online     — آنلاین/آفلاین (birth/LWT)
tele/{serial}/event      — رویداد تغییر وضعیت

# ابر → دستگاه
cmnd/{serial}/power      — دستور ON/OFF
```

### انتشار وضعیت آزمایشی (local)

```bash
mosquitto_pub -h localhost -p 1883 -u smartplug-backend -P devpass \
  -t "tele/SP00000001/state" \
  -m '{"power":"off","connectivity":"online"}'
```

### انتشار روی VPS

```bash
mosquitto_pub -h 46.31.79.157 -p 1883 -u smartplug-backend -P 'رمز-شما' \
  -t "tele/SP00000001/state" \
  -m '{"power":"on","connectivity":"online"}'
```

### گوش دادن به دستورات

```bash
mosquitto_sub -h localhost -p 1883 -u smartplug-backend -P devpass -t "cmnd/#" -v
```

### اسکریپت‌های آماده

```powershell
# ویندوز
.\deploy\scripts\mqtt-test.ps1 -Mode local
.\deploy\scripts\mqtt-test.ps1 -Mode remote -Serial SP00000001
```

```bash
# لینوکس / مک
./deploy/scripts/mqtt-test.sh local
./deploy/scripts/mqtt-test.sh remote
```

پس از publish، داشبورد باید دستگاه را با وضعیت به‌روز نشان دهد (REST + WebSocket).

## ۶. توقف و پاک‌سازی

```bash
docker compose down
```

Volumeهای `pgdata` و `mosquitto_*` داده را نگه می‌دارند. برای پاک‌سازی کامل: `docker compose down -v`.

## عیب‌یابی

| مشکل | راه‌حل |
|------|--------|
| API به DB وصل نمی‌شود | Postgres روی پورت **5433** است؛ `docker compose exec api alembic upgrade head` |
| MQTT رد اتصال (local) | `docker compose ps` — سرویس `mosquitto` باید healthy باشد؛ پروفایل `local-mqtt` فعال باشد |
| MQTT رد اتصال (VPS) | فایروال پورت **1883** را باز کنید: `sudo ufw allow 1883/tcp` — [MQTT_SETUP.md](MQTT_SETUP.md) |
| Mosquitto فقط روی 127.0.0.1 | در `/etc/mosquitto/mosquitto.conf` خط `include_dir /etc/mosquitto/conf.d` را **از کامنت خارج** کنید — [MQTT_SETUP.md](MQTT_SETUP.md) |
| Admin خطای 403 | شماره در `PLATFORM_ADMIN_PHONES` (E.164)، سپس `docker compose restart api` |
| OTP کار نمی‌کند | `ENVIRONMENT=development`؛ لاگ API را ببینید |
| وب API اشتباه می‌زند | `NEXT_PUBLIC_API_URL` در `.env`، rebuild سرویس `web` |

## مستندات مرتبط

- [VPS_DEPLOY.md](VPS_DEPLOY.md) — استقرار کل پلتفرم روی سرور
- [MQTT_VPS_AND_LOCAL.md](MQTT_VPS_AND_LOCAL.md) — انتخاب local در مقابل VPS
- [QUICKSTART_DOCKER.md](QUICKSTART_DOCKER.md) — راه‌اندازی سریع Docker
- [MQTT_SETUP.md](MQTT_SETUP.md) — Mosquitto روی Ubuntu/VPS
- [ADMIN_GUIDE.md](ADMIN_GUIDE.md) — پنل مدیریت
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) — استقرار تولید
- [../README.md](../README.md) — فهرست کامل مستندات
