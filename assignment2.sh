#!/bin/bash

set -e

echo "Starting assignment2.sh script..."

# Function to print headers
header() {
  echo
  echo "==== $1 ===="
}

header "Configuring netplan for 192.168.16.21"

NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

if grep -q "192.168.16.21" $NETPLAN_FILE; then
  echo "IP address already configured."
else
  echo "Updating netplan config..."
  # Backup original
  cp $NETPLAN_FILE ${NETPLAN_FILE}.bak
  # Replace or add configuration for 192.168.16.21 here
  # (You will need to modify this section according to actual config)
fi

header "Updating /etc/hosts"

if grep -q "192.168.16.21 server1" /etc/hosts; then
  echo "/etc/hosts already updated."
else
  # Remove old IP for server1 if exists
  sed -i '/server1/d' /etc/hosts
  echo "192.168.16.21 server1" >> /etc/hosts
  echo "/etc/hosts updated."
fi

header "Installing apache2 and squid"

if ! dpkg -l | grep -qw apache2; then
  apt update
  apt install -y apache2
  systemctl enable apache2
  systemctl start apache2
else
  echo "apache2 already installed."
fi

if ! dpkg -l | grep -qw squid; then
  apt install -y squid
  systemctl enable squid
  systemctl start squid
else
  echo "squid already installed."
fi

header "Creating users and setting up SSH keys"

USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

for user in "${USERS[@]}"; do
  if id "$user" &>/dev/null; then
    echo "User $user exists."
  else
    useradd -m -s /bin/bash "$user"
    echo "User $user created."
  fi

  SSH_DIR="/home/$user/.ssh"
  AUTH_KEYS="$SSH_DIR/authorized_keys"
  
  mkdir -p "$SSH_DIR"
  touch "$AUTH_KEYS"
  chmod 700 "$SSH_DIR"
  chmod 600 "$AUTH_KEYS"
  chown -R "$user:$user" "$SSH_DIR"

  
done

header "Adding dennis to sudo group"

usermod -aG sudo dennis

header "Adding public key for dennis"

DENNIS_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"

grep -qxF "$DENNIS_KEY" /home/dennis/.ssh/authorized_keys || echo "$DENNIS_KEY" >> /home/dennis/.ssh/authorized_keys

echo "Done."

