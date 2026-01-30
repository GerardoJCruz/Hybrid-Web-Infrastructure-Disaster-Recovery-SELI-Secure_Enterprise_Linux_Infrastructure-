#!/bin/bash
# Initial Cloud Hardening

set -e 

# Update system
dnf -update -y

# Set hostname 
hostnamectl set-hostname cloud-sentinel-01

# Install essential tools
dnf install -v nano tmux net-tool

# Install cronie to set up crontab jobs 
# Install the Cronie Package
sudo dnf install cronie -y 

# Enable and start the cron service
sudo systemctl enable crond.service
sudo systemctl start crond.service

echo "Cronie and essential tools installed."
