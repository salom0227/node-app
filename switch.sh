#!/bin/bash
set -e

APP_DIR="/home/deploy/apps/node-app"
NGINX_DIR="$APP_DIR/nginx"
ACTIVE_FILE="$NGINX_DIR/active_color.txt"

cd "$APP_DIR"

echo "=== ZERO-DOWNTIME TRAFFIC SWITCH ==="

# 1️⃣ active_color.txt yo‘q bo‘lsa — init
if [ ! -f "$ACTIVE_FILE" ]; then
  echo "active_color.txt not found, initializing with blue"
  mkdir -p "$NGINX_DIR"
  echo "blue" > "$ACTIVE_FILE"
fi

ACTIVE_COLOR=$(cat "$ACTIVE_FILE")
echo "Current active color: $ACTIVE_COLOR"

# 2️⃣ Qaysiga o‘tamiz?
if [ "$ACTIVE_COLOR" = "blue" ]; then
  NEW_COLOR="green"
  OLD_CONTAINER="node-blue"
  NEW_CONTAINER="node-green"
else
  NEW_COLOR="blue"
  OLD_CONTAINER="node-green"
  NEW_CONTAINER="node-blue"
fi

echo "Switching traffic to: $NEW_COLOR"

# 3️⃣ Yangi container tirikligini tekshiramiz
echo "Checking $NEW_CONTAINER health..."
docker ps | grep "$NEW_CONTAINER" >/dev/null || {
  echo "ERROR: $NEW_CONTAINER is not running"
  exit 1
}

# 4️⃣ Nginx upstream’ni almashtiramiz
cat > "$NGINX_DIR/upstream.conf" <<EOF
upstream node_app {
    server $NEW_CONTAINER:3000;
}
EOF

# 5️⃣ Nginx test + reload
nginx -t
systemctl reload nginx

# 6️⃣ active_color.txt yangilaymiz
echo "$NEW_COLOR" > "$ACTIVE_FILE"

echo "Traffic successfully switched to $NEW_COLOR"
echo "=== DONE ==="

