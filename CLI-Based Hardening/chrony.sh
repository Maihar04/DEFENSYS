#!/bin/bash

# Only run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo ./ntp_sync_check.sh)"
  exit 1
fi

echo "🔍 Checking if 'chrony' is installed..."

# Check if chrony is installed
if rpm -q chrony &>/dev/null || dpkg -l | grep -qw chrony; then
    echo "✅ Chrony is already installed."
else
    echo "⚠️  Chrony is not installed. Installing now..."

    # Install based on package manager
    if command -v dnf &>/dev/null; then
        dnf install -y chrony
    elif command -v apt &>/dev/null; then
        apt update && apt install -y chrony
    else
        echo "❌ Package manager not supported."
        exit 1
    fi
fi

# Enable and start chronyd service
echo "⚙️  Enabling and starting chronyd service..."
systemctl enable chronyd
systemctl start chronyd

# Configure default NTP servers if not present
CHRONY_CONF="/etc/chrony.conf"
if grep -q "pool" "$CHRONY_CONF"; then
    echo "📁 NTP servers already configured in $CHRONY_CONF"
else
    echo "📝 Adding default NTP server pool..."
    echo -e "\n# Default NTP server pool\npool pool.ntp.org iburst" >> "$CHRONY_CONF"
fi

# Restart chronyd to apply config
echo "🔄 Restarting chronyd to apply changes..."
systemctl restart chronyd

# Check status
echo "✅ Chrony is now active and running."
chronyc tracking


