#!/bin/bash
set -e

echo "[INFO] Configuring SSH GatewayPorts on cloud-sentinel-01"

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak"

# Backup once
if [ ! -f "$BACKUP" ]; then
    sudo cp "$SSHD_CONFIG" "$BACKUP"
fi

# Ensure GatewayPorts yes
if grep -q "^GatewayPorts" "$SSHD_CONFIG"; then
    sudo sed -i 's/^GatewayPorts.*/GatewayPorts yes/' "$SSHD_CONFIG"
else
    echo "GatewayPorts yes" | sudo tee -a "$SSHD_CONFIG" > /dev/null
fi

# Validate SSH config before restart (VERY important)
sudo sshd -t

# Restart SSH safely
sudo systemctl restart sshd

echo "[OK] cloud-sentinel-01 SSH gateway ready"
