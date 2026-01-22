#!/bin/bash
#Stage 6: security hardening (firewall + fail2ban)

set -e


# VARIABLES
CUSTOM_SSH_PORT=2222
LOG_UDP_PORT=514

OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

echo "Detected OS: $OS_ID"


# FIREWALL CONFIGURATION
configure_firewall_almalinux() {
    echo "Configuring firewalld (AlmaLinux)..."

    sudo systemctl enable --now firewalld

    sudo firewall-cmd --permanent --add-port=${CUSTOM_SSH_PORT}/tcp
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --remove-service=ssh

    sudo firewall-cmd --reload
    sudo firewall-cmd --list-all
}

configure_firewall_debian() {
    echo "Configuring UFW (Debian)..."

    sudo ufw allow ${CUSTOM_SSH_PORT}/tcp
    sudo ufw allow ${LOG_UDP_PORT}/udp

    sudo ufw --force enable
    sudo ufw status verbose
}

# FAIL2BAN CONFIGURATION
configure_fail2ban() {
    echo "Configuring Fail2Ban..."

    JAIL_LOCAL="/etc/fail2ban/jail.local"

    sudo tee "$JAIL_LOCAL" > /dev/null <<EOF
[sshd]
enabled = true
port = ${CUSTOM_SSH_PORT}
filter = sshd
logpath = %(sshd_log)s
maxretry = 3
findtime = 10m
bantime = 1h
EOF

    sudo systemctl enable --now fail2ban
    sudo systemctl restart fail2ban
}

# OS DECISION LOGIC
case "$OS_ID" in
    almalinux|rhel|centos)
        configure_firewall_almalinux
        configure_fail2ban
        ;;
    debian)
        configure_firewall_debian
        configure_fail2ban
        ;;
    *)
        echo "Unsupported OS: $OS_ID"
        exit 1
        ;;
esac

echo " Security hardening completed successfully."
