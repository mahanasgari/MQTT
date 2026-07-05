#!/usr/bin/env bash
# Start full SmartPlug dev stack (Postgres + Mosquitto + API + Web)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example — review before production use."
fi

# Generate Mosquitto password file if missing (smartplug-backend / devpass)
if [ ! -f deploy/mosquitto/passwd ]; then
  echo "Creating Mosquitto passwd (smartplug-backend / devpass)..."
  docker run --rm \
    -v "$ROOT/deploy/mosquitto:/mosquitto/config" \
    eclipse-mosquitto:2 \
    mosquitto_passwd -b /mosquitto/config/passwd smartplug-backend devpass
fi

docker compose --profile local-mqtt -f docker-compose.yml -f docker-compose.local-mqtt.yml up -d --build

echo "Waiting for API health..."
for i in $(seq 1 30); do
  if curl -sf http://localhost:8000/health >/dev/null 2>&1; then
    echo "API is healthy."
    break
  fi
  sleep 2
done

echo ""
echo "Stack ready:"
echo "  Web:      http://localhost:3000/fa/login"
echo "  API:      http://localhost:8000"
echo "  MQTT:     localhost:1883 (user: smartplug-backend, pass: devpass)"
echo "  Postgres: localhost:5433"
echo ""
echo "Test MQTT:"
echo "  mosquitto_pub -h localhost -p 1883 -u smartplug-backend -P devpass -t tele/SP00000001/state -m '{\"power\":\"off\",\"connectivity\":\"online\"}'"
