#!/bin/bash
set -e

AWS_USER="ec2-user"
AWS_IP="YOUR_AWS_PUBLIC_IP"
SSH_KEY="/home/admin/.ssh/lab-cloud-key.pem"
SERVICE_FILE="/etc/systemd/system/reverse-ssh-tunnel.service"
RUN_AS_USER="admin"

echo "[INFO] Creating persistent reverse SSH tunnel"

# Verify key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "[ERROR] SSH key not found at $SSH_KEY"
    exit 1
fi

# Create systemd service
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Reverse SSH Tunnel to AWS (8080 -> local 80)
After=network-online.target
Wants=network-online.target

[Service]
User=$RUN_AS_USER
ExecStart=/usr/bin/ssh -N \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -i $SSH_KEY \
    -R 8080:localhost:80 \
    $AWS_USER@$AWS_IP
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload and enable
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now reverse-ssh-tunnel

echo "[OK] Reverse tunnel active"

