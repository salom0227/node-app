#!/bin/bash
set -e

APP_PORT=3000
TIMEOUT=15

ACTIVE_FILE="./nginx/active_color.txt"

# Hozirgi rangni o‘qiymiz
CURRENT=$(cat "$ACTIVE_FILE" 2>/dev/null || echo "blue")

if [ "$CURRENT" = "blue" ]; then
  NEXT="green"
else
  NEXT="blue"
fi

echo "=============================="
echo "Current active: $CURRENT"
echo "Trying to switch to: $NEXT"
echo "=============================="

# Health check (curl o‘rniga nc)
HEALTHY=false

for i in $(seq 1 $TIMEOUT); do
  echo "Health check attempt $i/$TIMEOUT ..."
  if docker exec node-$NEXT sh -c "nc -z localhost $APP_PORT"; then
    HEALTHY=true
    echo "✅ $NEXT is healthy"
    break
  fi
  sleep 1
done

# Agar sog‘lom bo‘lmasa → rollback
if [ "$HEALTHY" != "true" ]; then
  echo "❌ $NEXT failed — ROLLBACK (traffic stays on $CURRENT)"
  exit 1
fi

# Trafikni almashtiramiz
echo "$NEXT" > "$ACTIVE_FILE"

# Nginx reload (downtime yo‘q)
docker exec global-nginx nginx -s reload

echo "=============================="
echo "🚀 Traffic successfully switched to $NEXT"
echo "=============================="
