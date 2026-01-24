#!/bin/bash
set -e

APP_DIR=/home/deploy/apps/node-app
NGINX_DIR=$APP_DIR/nginx
ACTIVE_FILE=$NGINX_DIR/active_color.txt

ACTIVE=$(cat $ACTIVE_FILE)

if [ "$ACTIVE" = "blue" ]; then
  NEW="green"
  PORT=3002
else
  NEW="blue"
  PORT=3001
fi

echo "Deploying to $NEW (port $PORT)"

# Health check (auth'dan mustaqil)
for i in {1..10}; do
  if curl -sf http://127.0.0.1:$PORT/healthz >/dev/null; then
    echo "Health OK on $NEW"
    break
  fi
  sleep 2
done

# Switch nginx upstream
echo "server 127.0.0.1:$PORT;" > $NGINX_DIR/upstream.conf
docker exec global-nginx nginx -s reload

# Mark active
echo $NEW > $ACTIVE_FILE
echo "Traffic switched to $NEW"

