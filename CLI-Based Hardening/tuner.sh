#!/bin/bash

CONFIG_FILE="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak"

# Desired values
DESIRED_INTERVAL=15
DESIRED_COUNT=3

echo "📂 SSH Configuration File: $CONFIG_FILE"

# Backup first
echo "🔄 Creating backup of sshd_config at $BACKUP_FILE..."
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Extract current values (even if commented, get latest match)
CURRENT_INTERVAL=$(grep -E '^\s*#?\s*ClientAliveInterval' "$CONFIG_FILE" | awk '{print $2}' | tail -n1)
CURRENT_COUNT=$(grep -E '^\s*#?\s*ClientAliveCountMax' "$CONFIG_FILE" | awk '{print $2}' | tail -n1)

[[ -z "$CURRENT_INTERVAL" ]] && CURRENT_INTERVAL="NOT SET"
[[ -z "$CURRENT_COUNT" ]] && CURRENT_COUNT="NOT SET"

echo -e "\n🧐 Current SSH Settings:"
echo "  ➤ ClientAliveInterval : $CURRENT_INTERVAL"
echo "  ➤ ClientAliveCountMax : $CURRENT_COUNT"

read -p $'\n❓ Do you want to set ClientAliveInterval to 15 and ClientAliveCountMax to 3? (y/n): ' confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then

    echo -e "\n⚙️ Applying changes..."

    # Modify or append ClientAliveInterval
    if grep -qE '^\s*#?\s*ClientAliveInterval' "$CONFIG_FILE"; then
        sed -i 's|^\s*#\?\s*ClientAliveInterval.*|ClientAliveInterval 15|' "$CONFIG_FILE"
    else
        echo "ClientAliveInterval 15" >> "$CONFIG_FILE"
    fi

    # Modify or append ClientAliveCountMax
    if grep -qE '^\s*#?\s*ClientAliveCountMax' "$CONFIG_FILE"; then
        sed -i 's|^\s*#\?\s*ClientAliveCountMax.*|ClientAliveCountMax 3|' "$CONFIG_FILE"
    else
        echo "ClientAliveCountMax 3" >> "$CONFIG_FILE"
    fi

    echo "✅ Changes applied to $CONFIG_FILE"

    # Test SSH config before restart
    echo "🔍 Testing SSH config before restarting..."
    if sshd -t; then
        echo "✅ SSH config syntax is valid. Restarting sshd..."
        systemctl restart sshd && echo "✅ sshd restarted successfully." || echo "❌ Failed to restart sshd."
    else
        echo "❌ SSH config has syntax errors. Not restarting."
        echo "🧯 Restoring original config from backup..."
        cp "$BACKUP_FILE" "$CONFIG_FILE"
        echo "🔁 Attempting to restart sshd with restored config..."
        systemctl restart sshd && echo "✅ sshd restored and restarted successfully." || echo "❌ Even rollback failed! Check manually."
        exit 1
    fi

    # ✅ Show updated values
    echo -e "\n📄 Updated SSH Settings:"
    UPDATED_INTERVAL=$(grep -Ei '^\s*ClientAliveInterval' "$CONFIG_FILE" | awk '{print $2}' | tail -n1)
    UPDATED_COUNT=$(grep -Ei '^\s*ClientAliveCountMax' "$CONFIG_FILE" | awk '{print $2}' | tail -n1)

    echo "  ➤ ClientAliveInterval : $UPDATED_INTERVAL"
    echo "  ➤ ClientAliveCountMax : $UPDATED_COUNT"

else
    echo "❌ No changes made. Exiting..."
fi

