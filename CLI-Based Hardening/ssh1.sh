#!/bin/bash

# Define allowed users
ALLOWED_USERS=("alloweduser" "testuser" "jay1")
SSH_CONFIG="/etc/ssh/sshd_config"
DEFAULT_SSH_PORT=22
NEW_SSH_PORT=2222

# Backup the original SSH config
cp $SSH_CONFIG "${SSH_CONFIG}.backup"
echo "Backing up existing SSH config..."

# Step 1: Change the SSH port back to 22
sed -i "s/^Port $NEW_SSH_PORT/Port $DEFAULT_SSH_PORT/" $SSH_CONFIG
sed -i "s/^#Port $DEFAULT_SSH_PORT/Port $DEFAULT_SSH_PORT/" $SSH_CONFIG  # Ensure default port is uncommented

# Step 2: Remove any existing AllowUsers line
sed -i '/^AllowUsers/d' $SSH_CONFIG

# Step 3: Add new AllowUsers line with the allowed users
echo -n "AllowUsers" >> $SSH_CONFIG
for user in "${ALLOWED_USERS[@]}"; do
    echo -n " $user" >> $SSH_CONFIG
done
echo "" >> $SSH_CONFIG  # Newline at end

echo "Updated SSH configuration to whitelist: ${ALLOWED_USERS[*]} and reverted port to $DEFAULT_SSH_PORT."

# Step 4: Restart the SSH service
systemctl restart sshd
echo "SSH service restarted. Only ${ALLOWED_USERS[*]} can now access SSH on port $DEFAULT_SSH_PORT."

# Step 5: Configure the firewall to allow port 22 and block port 2222
echo "Configuring firewall..."

# Allow port 22 and block port 2222
sudo firewall-cmd --permanent --add-port=$DEFAULT_SSH_PORT/tcp
sudo firewall-cmd --permanent --remove-port=$NEW_SSH_PORT/tcp
sudo firewall-cmd --reload

echo "Firewall updated: Port $DEFAULT_SSH_PORT allowed, Port $NEW_SSH_PORT blocked."

# Step 6: Remove iptables rule to allow port 22 and unblock port 2222
echo "Reverting iptables rules..."

# Remove the rule that blocks port 2222
sudo iptables -D INPUT -p tcp --dport $NEW_SSH_PORT -j ACCEPT

# Allow inbound traffic on port 22
sudo iptables -A INPUT -p tcp --dport $DEFAULT_SSH_PORT -m conntrack --ctstate NEW -j ACCEPT

# Save iptables rules
sudo service iptables save

# Step 7: Restart sshd (if not already done)
systemctl restart sshd
echo "SSH service has been restarted and configured to run on port $DEFAULT_SSH_PORT."

# Step 8: Confirm SSH is running on port 22
ss -tuln | grep :$DEFAULT_SSH_PORT

