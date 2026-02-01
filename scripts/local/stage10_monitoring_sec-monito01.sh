#!/bin/bash
set -euo pipefail

# CONFIGURATION

AWS_USER="ec2-user"
AWS_IP="YOUR_AWS_PUBLIC_IP"
SSH_KEY="/home/admin/.ssh/lab-cloud-key.pem"
SOURCE_LOG="/var/log/syslog"
DEST_DIR="/home/ec2-user/backups"
LOG_FILE="/var/log/cloud_backup.log"

# PRE-FLIGHT CHECKS

if [ ! -f "$SSH_KEY" ]; then
    echo "$(date) ERROR: SSH key not found" >> "$LOG_FILE"
    exit 1
fi

# BACKUP EXECUTION

rsync -avz \
    -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=accept-new" \
    "$SOURCE_LOG" \
    "${AWS_USER}@${AWS_IP}:${DEST_DIR}/" \
    >> "$LOG_FILE" 2>&1

echo "$(date) Backup completed successfully" >> "$LOG_FILE"

