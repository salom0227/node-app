#!/bin/bash
set -e

APP_DIR="/home/deploy/apps/node-app"
NGINX_DIR="$APP_DIR/nginx"
ACTIVE_FILE="$NGINX_DIR/active_color.txt"

cd "$APP_DIR"

echo "=== ZERO-DOWNTIME TRAFFIC SWITCH ==="

# active_color init
if [ ! -f "$ACTIVE_FILE" ]; then
  mkdir -p "$NGINX_DIR"
  echo "blue" > "$ACTIVE_FILE"
fi

ACTIVE_COLOR=$(cat "$ACTIVE_FILE")

if [ "$ACTIVE_COLOR" = "blue" ]; then
  NEW_COLOR="green"
  NEW_CONTAINER="node-green"
else
  NEW_COLOR="blue"
  NEW_CONTAINER="node-blue"
fi

echo "Switching traffic to $NEW_COLOR"

# container tekshiruvi
docker ps | grep "$NEW_CONTAINER" >/dev/null

# upstream yangilash
cat > "$NGINX_DIR/upstream.conf" <<EOF
upstream node_app {
    server $NEW_CONTAINER:3000;
}
EOF

# 🔥 MUHIM: SYSTEM NGINX YO‘Q
# 🔥 SHU YERDA XATO BOR EDI, OLIB TASHLANDI
# nginx -t
# systemctl reload nginx

# agar nginx docker ichida bo‘lsa
docker exec nginx nginx -s reload || true

echo "$NEW_COLOR" > "$ACTIVE_FILE"

echo "=== SWITCH DONE ==="
