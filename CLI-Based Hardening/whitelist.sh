#!/bin/bash

# Define allowed users
ALLOWED_USERS=("alloweduser" "testuser" "jay1")
SSH_CONFIG="/etc/ssh/sshd_config"

# Backup the original SSH config
cp $SSH_CONFIG "${SSH_CONFIG}.backup"

echo "Backing up existing SSH config..."

# Remove any existing AllowUsers line
sed -i '/^AllowUsers/d' $SSH_CONFIG

# Add new AllowUsers line with the allowed users
echo -n "AllowUsers" >> $SSH_CONFIG
for user in "${ALLOWED_USERS[@]}"; do
    echo -n " $user" >> $SSH_CONFIG
done
echo "" >> $SSH_CONFIG  # Newline at end

echo "Updated SSH configuration to whitelist: ${ALLOWED_USERS[*]}"

# Restart SSH service
systemctl restart sshd

echo "SSH service restarted. Only ${ALLOWED_USERS[*]} can now access SSH."

