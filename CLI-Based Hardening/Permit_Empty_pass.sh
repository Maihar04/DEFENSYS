#!/bin/bash

echo "🔒 [Audit] Checking SSH setting: PermitEmptyPasswords..."

# Step 1: Run the audit check
perm_value=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep permitemptypasswords)

echo "🔍 Current sshd setting: $perm_value"

# Step 2: Check for explicit 'yes' value in sshd_config
grep_output=$(grep -Ei '^\s*PermitEmptyPasswords\s+yes' /etc/ssh/sshd_config)

if [[ "$perm_value" == "permitemptypasswords no" && -z "$grep_output" ]]; then
    echo "✅ [Secure] SSH is correctly configured. Empty password logins are not allowed."
    exit 0
else
    echo -e "\n⚠️  [Warning] SSH may allow empty password logins. This is a potential security risk."
    echo "Would you like to remediate this and set 'PermitEmptyPasswords no' in /etc/ssh/sshd_config?"
    read -p "🛠️  Type 'yes' to proceed with remediation, or anything else to cancel: " admin_input

    if [[ "$admin_input" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
        echo -e "\n🔧 Applying fix..."

        # Backup sshd_config first
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        echo "📦 Backup created at /etc/ssh/sshd_config.bak"

        # Replace or append the config line
        if grep -Ei '^\s*PermitEmptyPasswords' /etc/ssh/sshd_config > /dev/null; then
            sed -i 's/^\s*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
        else
            echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
        fi

        # Restart SSH service
        echo "🔄 Restarting sshd service..."
        systemctl restart sshd

        echo "✅ Remediation complete. 'PermitEmptyPasswords' is now set to 'no'."
    else
        echo -e "\n❌ No changes were made. Administrator chose not to apply remediation."
        exit 1
    fi
fi


