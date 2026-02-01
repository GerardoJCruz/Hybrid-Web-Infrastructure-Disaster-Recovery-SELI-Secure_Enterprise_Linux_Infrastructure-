#!/bin/bash
set -e

echo "[INFO] Stage 9: Configuring Nginx Reverse Proxy on cloud-sentinel-01"

NGINX_CONF="/etc/nginx/conf.d/lab_proxy.conf"
NGINX_LOG="/var/log/nginx_errors.log"

# 1. Install Nginx if missing
if ! rpm -q nginx &>/dev/null; then
    sudo dnf install -y nginx
fi

# 2. Enable & start Nginx
sudo systemctl enable --now nginx

# 3. Remove default config to avoid conflicts (safe on AL2023)
sudo rm -f /etc/nginx/conf.d/default.conf

# 4. Create reverse proxy configuration
sudo tee "$NGINX_CONF" > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_http_version 1.1;
        proxy_buffering off;
    }
}
EOF

# 5. SELinux: allow Nginx to connect to tunnel port
sudo setsebool -P httpd_can_network_connect 1

# 6. Validate Nginx configuration BEFORE restart
if sudo nginx -t &>> "$NGINX_LOG"; then
    sudo systemctl restart nginx
else
    echo "[ERROR] Nginx config validation failed. Check $NGINX_LOG"
    exit 1
fi

echo "[OK] Stage 9 Cloud Gateway configured successfully"

