#!/bin/bash
set -e

APP_PORT=3000
TIMEOUT=10

ACTIVE_FILE="./nginx/active_color.txt"

CURRENT=$(cat $ACTIVE_FILE 2>/dev/null || echo "blue")

if [ "$CURRENT" = "blue" ]; then
  NEXT="green"
else
  NEXT="blue"
fi

echo "Current: $CURRENT"
echo "Trying to switch to: $NEXT"

# Health check
for i in $(seq 1 $TIMEOUT); do
  if docker exec node-$NEXT curl -s http://localhost:$APP_PORT >/dev/null; then
    echo "✅ $NEXT is healthy"
    break
  fi
  sleep 1
done

# Agar sog‘lom bo‘lmasa — rollback
if ! docker exec node-$NEXT curl -s http://localhost:$APP_PORT >/dev/null; then
  echo "❌ $NEXT failed — ROLLBACK"
  exit 1
fi

# Traffic switch
echo $NEXT > $ACTIVE_FILE

docker exec global-nginx nginx -s reload

echo "🚀 Switched traffic to $NEXT"

