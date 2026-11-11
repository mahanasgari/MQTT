# راه‌اندازی سریع با Docker

اجرای کامل پلتفرم اسمارت‌پلاگ روی سیستم محلی: **PostgreSQL**، **Mosquitto MQTT**، **FastAPI** و **Next.js**.

## پیش‌نیازها

- Docker Desktop (یا Docker Engine + Compose نسخه ۲)
- Git

## ۱. تنظیم محیط

```bash
cp .env.example .env
```

اعتبار MQTT پیش‌فرض توسعه:

| تنظیم | مقدار |
|-------|-------|
| کاربر MQTT | `smartplug-backend` |
| رمز MQTT | `devpass` |
| API | `http://localhost:8000` |
| وب | `http://localhost:3000` |
| Postgres | `localhost:5433` |

شماره موبایل خود را در `PLATFORM_ADMIN_PHONES` (فرمت E.164) قرار دهید تا پس از ورود به `/admin` دسترسی داشته باشید.

## ۲. اجرای سرویس‌ها

**لینوکس / مک:**

```bash
chmod +x deploy/scripts/docker-up.sh
./deploy/scripts/docker-up.sh
```

**ویندوز (PowerShell):**

```powershell
docker compose up -d --build
docker compose exec api alembic upgrade head
```

## ۳. بررسی سلامت سرویس‌ها

```bash
curl http://localhost:8000/health
```

مرورگر: http://localhost:3000/fa/login (یا `/en/login` برای انگلیسی)

## ۴. تست MQTT

انتشار وضعیت آزمایشی دستگاه (نیاز به [mosquitto-clients](https://mosquitto.org/download/) روی میزبان):

```bash
mosquitto_pub -h localhost -p 1883 -u smartplug-backend -P devpass \
  -t "tele/SP00000001/state" \
  -m '{"power":"off","connectivity":"online"}'
```

گوش دادن به دستورات:

```bash
mosquitto_sub -h localhost -p 1883 -u smartplug-backend -P devpass -t "cmnd/#" -v
```

## ۵. ثبت دستگاه

1. ورود در http://localhost:3000/fa/login (`?dev=1` برای OTP خودکار در حالت توسعه)
2. **دستگاه‌ها → افزودن دستگاه**
3. سریال `SP00000001`، دریافت توکن، ثبت و اتصال به خانه
4. دوباره MQTT state را منتشر کنید — داشبورد باید دستگاه را نشان دهد

یا از **مدیریت** (`/fa/admin`) برای ثبت سریال کارخانه و ایجاد توکن استفاده کنید.

## ۶. توقف

```bash
docker compose down
```

داده‌ها در volumeهای `pgdata` و `mosquitto_config` باقی می‌مانند.

## عیب‌یابی

| مشکل | راه‌حل |
|------|--------|
| API به DB وصل نمی‌شود | منتظر healthcheck بمانید؛ `docker compose exec api alembic upgrade head` |
| MQTT رد اتصال | `docker compose ps`؛ Mosquitto در اولین اجرا فایل passwd می‌سازد |
| آدرس API اشتباه در وب | `NEXT_PUBLIC_API_URL` در `.env`، سپس rebuild سرویس `web` |
| Admin خطای 403 | شماره در `PLATFORM_ADMIN_PHONES`، restart سرویس `api` |

## مستندات مرتبط

- [MQTT_SETUP.md](MQTT_SETUP.md) — پیکربندی Mosquitto تولید
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) — استقرار تولید
- [ADMIN_GUIDE.md](ADMIN_GUIDE.md) — پنل مدیریت پلتفرم
