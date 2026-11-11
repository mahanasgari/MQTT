#!/usr/bin/env bash
# Deploy SmartPlug on a VPS (Docker: db + mosquitto + api + web + nginx)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env — edit SECRET_KEY, MQTT_PASSWORD, PLATFORM_ADMIN_PHONES, NEXT_PUBLIC_API_URL"
fi

PUBLIC_HOST="${PUBLIC_HOST:-}"
if [ -z "$PUBLIC_HOST" ]; then
  PUBLIC_HOST="$(hostname -I 2>/dev/null | awk '{print $1}')" || true
fi
if [ -z "$PUBLIC_HOST" ]; then
  echo "Set PUBLIC_HOST to your VPS IP or domain, e.g. export PUBLIC_HOST=46.31.79.157"
  exit 1
fi

# Web is built with this URL baked in
export NEXT_PUBLIC_API_URL="${NEXT_PUBLIC_API_URL:-http://${PUBLIC_HOST}/v1}"
export NEXT_PUBLIC_DEFAULT_LOCALE="${NEXT_PUBLIC_DEFAULT_LOCALE:-fa}"
export CORS_ORIGINS="${CORS_ORIGINS:-http://${PUBLIC_HOST},http://${PUBLIC_HOST}:80}"

echo "Deploying with NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}"

docker compose -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.prod.yml exec -T api alembic upgrade head || true

echo "Waiting for health..."
for i in $(seq 1 40); do
  if curl -sf "http://127.0.0.1/health" >/dev/null 2>&1; then
    echo "Healthy."
    break
  fi
  sleep 2
done

echo ""
echo "Open:  http://${PUBLIC_HOST}/fa/login?dev=1"
echo "API:   http://${PUBLIC_HOST}/v1"
echo "MQTT:  ${PUBLIC_HOST}:1883  user=smartplug-backend"
echo "Allow 80 and 1883 in the firewall: sudo ufw allow 80/tcp && sudo ufw allow 1883/tcp"
