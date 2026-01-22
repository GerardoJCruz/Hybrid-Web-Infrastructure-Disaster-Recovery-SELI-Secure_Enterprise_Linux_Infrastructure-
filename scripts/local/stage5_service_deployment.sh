#!/bin/bash
#  Service Deployment (Nginx + Centralized Logging)
# Target: web-prod-01 (AlmaLinux)

set -e

LOG_FILE="/var/log/nginx_deploy.log"
WEB_ROOT="/usr/share/nginx/html"
CONF_FILE="/etc/nginx/conf.d/my_coffee.conf"
RSYSLOG_CONF="/etc/rsyslog.d/90-forward.conf"
LOG_TARGET="@192.168.56.20:514"


# Install and Configure Nginx

install_nginx() {

    #Installing Nginx if missing
    if ! rpm -q nginx &>/dev/null; then
        sudo dnf install -y nginx
    fi

    sudo systemctl enable nginx

    # Removing default Nginx configs (if any)
    sudo rm -f /etc/nginx/conf.d/default.conf

    # Ensuring web root exists
    sudo mkdir -p "$WEB_ROOT"
    sudo chown -R root:root "$WEB_ROOT"
    sudo chmod -R 755 "$WEB_ROOT"

    # [INFO] Creating dedicated Nginx server config
    cat <<EOF | sudo tee "$CONF_FILE" > /dev/null
server {
    listen 80;
    server_name _;

    root $WEB_ROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

    [INFO] Validating Nginx configuration
    if sudo nginx -t &>> "$LOG_FILE"; then
        sudo systemctl start nginx
        sudo systemctl reload nginx
        echo "Nginx deployed successfully"
    else
        echo "[ERROR] Nginx configuration failed. See $LOG_FILE"
        exit 1
    fi
}


# Configure rsyslog Forwarding
configure_log_forwarding() {

    # Configuring rsyslog forwarding

    if ! grep -q "$LOG_TARGET" "$RSYSLOG_CONF" 2>/dev/null; then
        echo "*.* $LOG_TARGET" | sudo tee "$RSYSLOG_CONF" > /dev/null
    fi

    # Validating rsyslog configuration
    sudo rsyslogd -N1

    sudo systemctl restart rsyslog
    # rsyslog forwarding enabled
}


# Verify Services
verify_services() {

    # Verify services

    systemctl is-active --quiet nginx \
        && echo "[OK] Nginx is running" \
        || echo "[WARN] Nginx is NOT running"

    systemctl is-active --quiet rsyslog \
        && echo "[OK] rsyslog is running" \
        || echo "[WARN] rsyslog is NOT running"
}


# Execution
install_nginx
configure_log_forwarding
verify_services

echo "Stage - Service Deployment Completed"
