#!/usr/bin/env bash
# Test MQTT publish to local or remote broker.
# Usage:
#   ./deploy/scripts/mqtt-test.sh local
#   ./deploy/scripts/mqtt-test.sh remote
#   MQTT_HOST=46.31.79.157 ./deploy/scripts/mqtt-test.sh

set -euo pipefail
MODE="${1:-local}"
SERIAL="${MQTT_SERIAL:-SP00000001}"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

USER="${MQTT_USERNAME:-smartplug-backend}"
PASS="${MQTT_PASSWORD:-devpass}"

if [ "$MODE" = "remote" ]; then
  HOST="${MQTT_BROKER_HOST:?Set MQTT_BROKER_HOST in .env}"
else
  HOST="${MQTT_HOST:-localhost}"
fi
PORT="${MQTT_BROKER_PORT:-1883}"

TOPIC="tele/${SERIAL}/state"
PAYLOAD='{"power":"off","connectivity":"online"}'

echo "Publishing to ${HOST}:${PORT} topic=${TOPIC}"
mosquitto_pub -h "$HOST" -p "$PORT" -u "$USER" -P "$PASS" -t "$TOPIC" -m "$PAYLOAD"
echo "OK — check dashboard or API logs for state update"
