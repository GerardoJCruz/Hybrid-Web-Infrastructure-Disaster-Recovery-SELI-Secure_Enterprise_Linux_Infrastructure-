## Post-Install Commands

#web-prod-01: AlmaLinux

```bash
# Update the system - AlmaLinux
sudo dnf update -y 

# Install essential tools

sudo dnf install -y vim nano curl wget net-tools 
```

#sec-monitor-01: Debian

```bash
# Update the system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y vim nano curl wget net-tools
```

## Automated Version

```bash
#!/bin/bash
# server_setup.sh
# Purpose: Baseline server configuration for Linux lab nodes

set -e

echo "Updating system..."
if command -v dnf &>/dev/null; then
    sudo dnf update -y
    sudo dnf install -y vim nano curl wget net-tools
elif command -v apt &>/dev/null; then
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y vim nano curl wget net-tools
else
    echo "Unsupported OS"
    exit 1
fi

echo "Baseline setup completed successfully."
