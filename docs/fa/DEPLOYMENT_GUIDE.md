# راهنمای استقرار (خلاصه فارسی)

نسخه خلاصه‌شده [DEPLOYMENT_GUIDE.md](../../DEPLOYMENT_GUIDE.md) برای تیم فارسی‌زبان.

## معماری

```
کاربر (وب/موبایل) → Nginx → FastAPI → PostgreSQL
                              ↘ Mosquitto ← دستگاه ESP8266
```

## توسعه محلی — Docker (توصیه شده)

```bash
cp .env.example .env
docker compose up -d --build
docker compose exec api alembic upgrade head
```

- وب: http://localhost:3000/fa/login
- API: http://localhost:8000
- MQTT: localhost:1883

راهنمای کامل: [QUICKSTART_DOCKER.md](QUICKSTART_DOCKER.md)

## متغیرهای مهم `.env`

| متغیر | توضیح |
|-------|--------|
| `SECRET_KEY` | کلید JWT — در تولید تصادفی |
| `ENVIRONMENT` | `production` در سرور واقعی |
| `DATABASE_URL` | Postgres — پورت 5433 در Docker محلی |
| `MQTT_BROKER_HOST` | `mosquitto` در Docker؛ IP VPS در تولید |
| `PLATFORM_ADMIN_PHONES` | شماره‌های ادمین پلتفرم |
| `REQUIRE_PREREGISTERED_SERIAL` | `true` برای حالت کارخانه |

## استقرار تولید (خلاصه)

1. VPS با Ubuntu
2. Docker Compose برای API + Postgres (یا Postgres مدیریت‌شده)
3. Mosquitto روی میزبان — [MQTT_SETUP.md](MQTT_SETUP.md)
4. Nginx + TLS برای API و وب
5. `ENVIRONMENT=production` — OTP واقعی (SMS) لازم است

## چک‌لیست امنیت

- [ ] `SECRET_KEY` تصادفی
- [ ] Postgres در اینترنت عمومی نیست
- [ ] Mosquitto: `allow_anonymous false` + ACL
- [ ] CORS فقط دامنه واقعی
- [ ] `PLATFORM_ADMIN_PHONES` فقط اپراتورها

## پنل مدیریت

پس از ورود با شماره ادمین: `/fa/admin` — [ADMIN_GUIDE.md](ADMIN_GUIDE.md)

## مستندات کامل انگلیسی

- [DEPLOYMENT_GUIDE.md](../../DEPLOYMENT_GUIDE.md)
- [DEVICE_PROVISIONING_FLOW.md](../../DEVICE_PROVISIONING_FLOW.md)
- [DEVICE_REGISTRATION_FLOW.md](../../DEVICE_REGISTRATION_FLOW.md)
