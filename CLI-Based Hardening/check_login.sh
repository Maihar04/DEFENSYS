#!/bin/bash

echo "🔒 [Audit] Checking SSH setting: LoginGraceTime..."

# Step 1: Get current effective value using sshd -T
grace_time=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep logingracetime | awk '{print $2}')

echo "🔍 Current LoginGraceTime from sshd: $grace_time seconds"

# Step 2: Check for invalid entries in sshd_config
bad_config=$(grep -Ei '^\s*LoginGraceTime\s+(0|6[1-9]|[7-9][0-9]|[1-9][0-9]{2,}|[^1]m)' /etc/ssh/sshd_config)

# Convert 1m to 60 for easier comparison
if [[ "$grace_time" == "1m" ]]; then
    grace_time=60
fi

# Step 3: Validate
if [[ "$grace_time" -le 60 && -z "$bad_config" ]]; then
    echo "✅ [Secure] LoginGraceTime is properly configured (<= 60 seconds)."
    exit 0
else
    echo -e "\n⚠️  [Warning] LoginGraceTime is not securely configured."
    echo "Would you like to set LoginGraceTime to 60 seconds in /etc/ssh/sshd_config?"
    read -p "🛠️  Type 'yes' to proceed with remediation, or anything else to cancel: " admin_input

    if [[ "$admin_input" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
        echo -e "\n🔧 Applying fix..."

        # Backup sshd_config first
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        echo "📦 Backup created at /etc/ssh/sshd_config.bak"

        # Replace or append the config line
        if grep -Ei '^\s*LoginGraceTime' /etc/ssh/sshd_config > /dev/null; then
            sed -i 's/^\s*LoginGraceTime.*/LoginGraceTime 60/' /etc/ssh/sshd_config
        else
            echo "LoginGraceTime 60" >> /etc/ssh/sshd_config
        fi

        # Restart SSH service
        echo "🔄 Restarting sshd service..."
        systemctl restart sshd

        echo "✅ Remediation complete. LoginGraceTime is now set to 60 seconds."
    else
        echo -e "\n❌ No changes were made. Administrator chose not to apply remediation."
        exit 1
    fi
fi

