# راهنمای پیکربندی MQTT (Mosquitto)

راهنمای فارسی برای راه‌اندازی بروکر MQTT در تولید و رفع خطاهای رایج.

## نقش MQTT در سیستم

| جزء | نقش |
|-----|-----|
| پریز ESP8266 | انتشار telemetry؛ دریافت دستور |
| بک‌اند FastAPI | اشتراک telemetry؛ ارسال دستور |
| اپ موبایل/وب | **مستقیم** به MQTT وصل نمی‌شوند — REST + WebSocket |

## تست سریع با Docker (توسعه)

برای تست فوری بدون VPS:

```bash
docker compose up -d
mosquitto_pub -h localhost -p 1883 -u smartplug-backend -P devpass \
  -t "tele/SP00000001/state" -m '{"power":"off","connectivity":"online"}'
```

جزئیات: [QUICKSTART_DOCKER.md](../QUICKSTART_DOCKER.md) یا [نسخه فارسی](QUICKSTART_DOCKER.md).

## نصب روی Ubuntu (VPS)

```bash
sudo apt update
sudo apt install -y mosquitto mosquitto-clients
sudo systemctl enable mosquitto
```

## پیکربندی تولید

فایل `/etc/mosquitto/conf.d/smartplug.conf` — ابتدا **فقط پورت 1883** (بدون TLS) تا گواهی آماده شود:

```conf
per_listener_settings true

listener 1883 0.0.0.0
protocol mqtt
allow_anonymous false
password_file /etc/mosquitto/passwd
acl_file /etc/mosquitto/acl
```

### خطای رایج: `include_dir` کامنت شده

اگر لاگ می‌گوید **Starting in local only mode** و فقط `127.0.0.1:1883` گوش می‌دهد:

1. در `/etc/mosquitto/mosquitto.conf` خط زیر را **از حالت کامنت خارج کنید**:
   ```conf
   include_dir /etc/mosquitto/conf.d
   ```
2. `sudo systemctl restart mosquitto`
3. بررسی: `sudo ss -tulpn | grep mosquitto` باید `0.0.0.0:1883` نشان دهد

### خطای رایج: `Duplicate persistence_location`

`persistence_location` فقط در **یک فایل** باشد — یا `mosquitto.conf` یا `conf.d/default.conf`، نه هر دو.

### خطای رایج: TLS بدون گواهی

اگر بلوک `listener 8883` با `cafile`/`certfile`/`keyfile` دارید و پوشه `/etc/mosquitto/certs/` خالی است، Mosquitto **اصلاً بالا نمی‌آید**. تا زمان نصب گواهی، بلوک 8883 را کامنت کنید.

## کاربر و رمز

```bash
sudo mosquitto_passwd -c /etc/mosquitto/passwd smartplug-backend
sudo chown root:mosquitto /etc/mosquitto/passwd
sudo chmod 640 /etc/mosquitto/passwd
```

در `.env` بک‌اند: `MQTT_USERNAME` و `MQTT_PASSWORD`.

## ACL

نمونه `/etc/mosquitto/acl`:

```conf
user smartplug-backend
topic readwrite tele/#
topic write cmnd/#

user device-SN-2026-000001
topic write tele/SN-2026-000001/#
topic read cmnd/SN-2026-000001/#
```

سریال در topic باید **دقیقاً** با `devices.serial` در دیتابیس یکی باشد.

## فایروال

```bash
sudo ufw allow 1883/tcp
# پس از TLS:
# sudo ufw allow 8883/tcp
```

## تست از راه دور

```bash
mosquitto_pub -h IP_VPS -p 1883 -u smartplug-backend -P 'رمز' -t test/hello -m ping
```

## مستندات انگلیسی

[MQTT_SETUP.md](../../MQTT_SETUP.md)
