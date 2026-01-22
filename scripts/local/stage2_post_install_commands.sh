#!/bin/bash
# server_baseline_2026.sh
# Purpose: Secure and automated baseline setup for AlmaLinux and Debian nodes.

set -euo pipefail  # Exit on error, undefined vars, or pipe failure
LOG_FILE="/var/log/server_setup_$(date +%F).log"

echo "Starting baseline setup. Logs available at $LOG_FILE" | tee -a "$LOG_FILE"

# Function to verify safety before applying
verify_system_health() {
    echo "Verifying system health..."
    if command -v dnf &>/dev/null; then
        # Check for DNF lock or database issues
        sudo dnf check >> "$LOG_FILE" 2>&1 || { echo "DNF health check failed. Resolve manually."; exit 1; }
    elif command -v apt &>/dev/null; then
        # Check for broken dependencies or interrupted installs
        sudo dpkg --audit >> "$LOG_FILE" 2>&1 || { echo "Broken packages detected. Run 'sudo apt install -f'."; exit 1; }
        sudo apt update -y >> "$LOG_FILE" 2>&1
    fi
}

# Main update logic
apply_updates() {
    if command -v dnf &>/dev/null; then
        echo "Updating AlmaLinux/RHEL-based system..."
        sudo dnf update -y >> "$LOG_FILE" 2>&1
        sudo dnf install -y vim nano curl wget net-tools >> "$LOG_FILE" 2>&1
    elif command -v apt &>/dev/null; then
        echo "Updating Debian-based system..."
        # Use DEBIAN_FRONTEND to prevent interactive prompts in automated scripts
        sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y >> "$LOG_FILE" 2>&1
        sudo apt install -y vim nano curl wget net-tools >> "$LOG_FILE" 2>&1
    else
        echo "Unsupported OS detected." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Execution
verify_system_health
apply_updates

echo "Baseline setup completed successfully at $(date)." | tee -a "$LOG_FILE"
