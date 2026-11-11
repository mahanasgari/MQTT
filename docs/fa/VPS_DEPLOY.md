# استقرار روی VPS

راهنمای اجرای **کل پلتفرم** روی سرور (وب + API + دیتابیس + MQTT).

آدرس نمونه شما: `46.31.79.157`

## چه چیزی روی سرور بالا می‌آید؟

| سرویس | پورت |
|--------|------|
| Nginx (وب + پروکسی API) | **80** |
| Mosquitto MQTT | **1883** |
| PostgreSQL | فقط داخل Docker |

ورود: `http://46.31.79.157/fa/login`

---

## ۱. روی VPS

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2 git curl ufw
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 1883/tcp
sudo ufw --force enable

git clone <repo-url> MQTT-Mobile-WEB
cd MQTT-Mobile-WEB
cp .env.example .env
```

در `.env` حداقل این‌ها را عوض کنید:

```env
SECRET_KEY=یک-رشته-تصادفی-بلند
MQTT_PASSWORD=رمز-mqtt
PLATFORM_ADMIN_PHONES=+989052755652
NEXT_PUBLIC_API_URL=http://46.31.79.157/v1
NEXT_PUBLIC_DEFAULT_LOCALE=fa
CORS_ORIGINS=http://46.31.79.157
ENVIRONMENT=development
```

> تا وقتی SMS OTP ندارید `ENVIRONMENT=development` بماند تا OTP در `docker compose logs api` چاپ شود و `?dev=1` کار کند.

اگر از قبل Mosquitto روی خود سرور (نه Docker) روی ۱۸۸۳ گوش می‌دهد، یا آن را متوقف کنید (`sudo systemctl stop mosquitto`) یا از حالت remote استفاده کنید (پایین).

```bash
export PUBLIC_HOST=46.31.79.157
chmod +x deploy/scripts/vps-up.sh
./deploy/scripts/vps-up.sh
```

یا دستی:

```bash
export NEXT_PUBLIC_API_URL=http://46.31.79.157/v1
docker compose -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.prod.yml exec api alembic upgrade head
curl http://127.0.0.1/health
```

باید شبیه این باشد: `{"ok":true,"db":"connected","mqtt":"connected"}`

---

## ۲. ورود و تست بدون سخت‌افزار

1. مرورگر: `http://46.31.79.157/fa/login?dev=1`
2. شماره ادمین را وارد کنید؛ OTP از لاگ: `docker compose -f docker-compose.prod.yml logs api | grep OTP`
3. داشبورد → **دستگاه آزمایشی محلی**
4. کلید روشن/خاموش باید کار کند
5. صفحه دستگاه → **شبیه‌سازی آنلاین**

---

## ۳. دستگاه واقعی (ESP) به MQTT سرور

بروکر: `46.31.79.157:1883`

| کاربر | رمز | نقش |
|--------|-----|-----|
| `smartplug-backend` | `MQTT_PASSWORD` در `.env` | API |
| `device` | `MQTT_DEVICE_PASSWORD` (پیش‌فرض `devicepass`) | firmware |

Firmware باید روی `tele/{SERIAL}/state` و `tele/{SERIAL}/online` منتشر کند و `cmnd/{SERIAL}/power` را گوش دهد.

سریال باید **دقیقاً** همان سریال ثبت‌شده در پنل باشد.

تست از لپ‌تاپ:

```bash
mosquitto_pub -h 46.31.79.157 -p 1883 -u device -P devicepass \
  -t tele/LOCAL-XXXX/state \
  -m '{"power":"off","connectivity":"online"}'
```

---

## ۴. اگر Mosquitto از قبل روی VPS نصب است

پشتهٔ Docker را **بدون** بروکر داخلی بالا بیاورید و API را به IP عمومی یا `172.17.0.1` وصل کنید:

روی لپ‌تاپ (API محلی + MQTT سرور):

```bash
# در .env: MQTT_BROKER_HOST=46.31.79.157
docker compose -f docker-compose.yml -f docker-compose.remote-mqtt.yml up -d
```

روی خود VPS اگر Mosquitto میزبان است نه کانتینر:

```env
MQTT_BROKER_HOST=172.17.0.1
```

و Mosquitto باید روی `0.0.0.0:1883` گوش دهد — [MQTT_SETUP.md](MQTT_SETUP.md).

---

## ۵. فایروال و Mosquitto میزبان

```bash
sudo ss -tulpn | grep 1883
# باید 0.0.0.0:1883 باشد نه 127.0.0.1
```

اگر «local only mode» است، در `/etc/mosquitto/mosquitto.conf`:

```
include_dir /etc/mosquitto/conf.d
```

ACL بک‌اند باید `tele/#` را **بنویسد** هم (برای شبیه‌سازی محلی). نمونه در `deploy/mosquitto/acl`.

---

## عیب‌یابی

| مشکل | کار |
|------|-----|
| وب سفید / API خطا | `NEXT_PUBLIC_API_URL` باید `http://IP/v1` باشد و **وب را دوباره build** کنید |
| `mqtt: disconnected` | لاگ api و رمز MQTT را چک کنید |
| دستگاه آفلاین می‌ماند | سریال، فایروال ۱۸۸۳، کاربر `device` |
| OTP نمی‌آید | `ENVIRONMENT=development` و `logs api` |

جزئیات MQTT: [MQTT_VPS_AND_LOCAL.md](MQTT_VPS_AND_LOCAL.md)
