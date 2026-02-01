#!/bin/bash
set -euo pipefail

# CONFIGURATION

TUNNEL_PORT="8080"
LOG_FILE="/var/log/tunnel_monitor.log"


# CHECK TUNNEL

if ! ss -tuln | grep -q ":${TUNNEL_PORT}"; then
    echo "$(date) ALERT: SSH reverse tunnel DOWN on port ${TUNNEL_PORT}" >> "$LOG_FILE"
else
    echo "$(date) OK: Tunnel healthy" >> "$LOG_FILE"
fi
