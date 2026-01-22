#!/bin/bash
# sudo_configuration

set -e 
ADMIN_GROUP="labadmins"
USER_NAME=$(whoami)

# Create admin group if it doesn' exits
if ! getent group "$ADMIN_GROUP" >dev/null; then
	sudo groupadd "$ADMIN_GROUP"
fi

# Add user to admin groups
sudo usermod -aG "$ADMIN_GROUP" "$USER_NAME"

if grep -qi almalinux /etc/os-release; then
	sudo usermod -aG wheel "$USER_NAME"
elif grep -qi debian /etc/os-release; then
	sudo usermod -aG sudo "$USER_NAME"
fi

# Configure sudoers
SUDO_LINE="%${ADMIN_GROUP} ALL=(ALL) ALL"
if ! sudo grep -q "^$SUDO_LINE" /etc/sudoers; then
	echo "$SUDO_LINE" | sudo EDITOR='tee -a' visudo
fi 

# Configure Password Policy
LOGIN_DEFS="/etc/login.defs"

declare -A PASS_POLICIES=(
	["PASS_MAX_DAYS"]="90"
	["PASS_MIN_DAYS"]="1"
	["PASS_WARN_AGE"]="7"
)

# Backup once for safty
sudo cp "$LOGIN_DEFS" "${LOGIN_DEFS}.bak"

for KEY in "${!PASS_POLICIES[@]}"; do
	LINE="$KEY ${PASS_POLICIES[$KEY]}"
	
	if sudo grep -q "^$KEY" "$LOGIN_DEFS"; then
		#Replace existing value
		sudo sed -i "s/^$KEY.*/$LINE/" "$LOGIN_DEFS"
	else
		# Append if missing
		echo "$LINE" | sudo tee -a "$LOGIN_DEFS" > /dev/null
	fi
done

echo "IAM configuration completed"

