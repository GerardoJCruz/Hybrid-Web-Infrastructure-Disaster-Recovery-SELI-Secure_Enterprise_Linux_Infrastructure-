#!/bin/bash
set -e

# Config based on server
HOST_ONLY_IFACE="enp0s8"
STATIC_IP="192.168.56.10"
NETMASK="/24"

WEB_IP="192.168.56.10"
SEC_IP="192.168.56.20"

WEB_HOST="web-prod-01"
SEC_HOST="sec-monitor-01"

SSH_PORT="2222"

# OS detection
if grep -qi almalinux /etc/os-release; then
	OS="almalinux"

elif grep -qi debian /etc/os-release; then
	OS="debian"
else 
	echo "Unsupported OS"
	exit 1
fi

# AlmaLinux Static IP Automation
 configure_network_alma() {
  local CON_NAME

  CON_NAME=$(nmcli -t -f NAME,DEVICE con show | grep ":$HOST_ONLY_IFACE$" | cut -d: -f1)

	# If $CON_NAME empty, auto-creation of nmcli connection
  if [ -z "$CON_NAME" ]; then
    echo "[INFO] No NetworkManager profile found for $HOST_ONLY_IFACE. Creating one."

    CON_NAME="hostonly-$HOST_ONLY_IFACE"
    nmcli con add type ethernet ifname "$HOST_ONLY_IFACE" con-name "$CON_NAME"
  fi

  nmcli con mod "$CON_NAME" \
    ipv4.method manual \
    ipv4.addresses "$STATIC_IP$NETMASK"

  nmcli con up "$CON_NAME"
}
 
# Debian Static IP Automation with Netplan
configure_network_debian_netplan() {
	#Uses a dedicate file to do not overwrite Netplan file
	NETPLAN_FILE="/etc/netplan/99-hostonly-static.yaml"
	
	sudo tee "$NETPLAN_FILE" > /dev/null <<EOF
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
    $HOST_ONLY_IFACE:
      addresses:
        - $STATIC_IP$NETMASK
EOF
	
	sudo netplan apply
}

# Debian Static IP Automation with Netplan
configure_network_debian_interface() {
	sudo cp /etc/network/interfaces /etc/network/interfaces.bak
	
	sudo tee /etc/network/interfaces > /dev/null <<E0F
	auto lo
	iface lo inet loopback
	
	auto enp0s3
	iface enp0s3 inet dhcp
	
	auto $HOST_ONLY_IFACE
	iface $HOST_ONLY_IFACE inet static
		address ${STATIC_IP}
		netmask 255.255.255.0 
	EOF

	sudo systemctl restart networking
}

# Define which method to use 
configure_network_debian() {
	if [ -d /etc/netplan ]; then 
		configure_network_debian_netplan
	else
		configure_network_debian_interface
	fi
}

if [ "$OS" = "almalinux" ]; then
	configure_network_alma
elif [ "$OS" = "debian" ]
	configure_network_debian
fi

# Autoamtion /etc/hosts
update_host(){

	sudo sed -i "/web-prod-01/d;/sec-monitor-01/d" /etc/hosts
	
	echo "$WEB_IP web-prod-01.local web-prod-01" | sudo tee -ad /etc/hosts > /dev/null
	echo "$SEC_IP sec-monitor-01.local sec-monitor-01" | sudo tee -a /etc/hosts > /dev/null
}

#Automation SSH hardening
configure_ssh() {
  sudo sed -i \
    -e "s/^#\?Port .*/Port $SSH_PORT/" \
    -e "s/^#\?PermitRootLogin .*/PermitRootLogin no/" \
    -e "s/^#\?MaxAuthTries .*/MaxAuthTries 3/" \
    /etc/ssh/sshd_config

  echo "[INFO] Validating SSH configuration..."

	# SSH config validated before restart.
  if ! sudo sshd -t; then
    echo "[ERROR] SSH configuration invalid. Aborting restart."
    exit 1
  fi

  if [ "$OS" = "almalinux" ]; then
    sudo systemctl restart sshd
  else
    sudo systemctl restart ssh
  fi
}

updates_host
configure_ssh
echo "[OK] Stage 4 Network Hardening Completed"
