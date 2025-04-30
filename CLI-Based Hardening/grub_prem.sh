#!/bin/bash

# Function to check file permission
check_permissions() {
    local file="$1"
    local expected_perm="$2"
    local expected_owner="0"
    local expected_group="0"

    if [ ! -f "$file" ]; then
        echo "⚠️  Skipping $file — file not found."
        return 2
    fi

    stat_out=$(stat -Lc "%a %u %g" "$file")
    read -r perm uid gid <<< "$stat_out"

    if [[ "$perm" -le "$expected_perm" && "$uid" -eq "$expected_owner" && "$gid" -eq "$expected_group" ]]; then
        echo "✅ $file has correct permissions: $perm, owner UID: $uid, GID: $gid"
        return 0
    else
        echo "⚠️  $file has incorrect permissions: $perm, UID: $uid, GID: $gid"
        return 1
    fi
}

# Function to remediate permissions
fix_permissions() {
    echo "🔧 Fixing permissions..."
    [ -f /boot/grub2/grub.cfg ] && chown root:root /boot/grub2/grub.cfg && chmod og-rwx /boot/grub2/grub.cfg
    [ -f /boot/grub2/grubenv ] && chown root:root /boot/grub2/grubenv && chmod u-x,og-rwx /boot/grub2/grubenv
    [ -f /boot/grub2/user.cfg ] && chown root:root /boot/grub2/user.cfg && chmod u-x,og-rwx /boot/grub2/user.cfg
    echo "✅ Permissions and ownership have been remediated (where applicable)."
}

# Main Logic
echo "🔍 Checking GRUB configuration file permissions..."

check_permissions "/boot/grub2/grub.cfg" 700; res1=$?
check_permissions "/boot/grub2/grubenv" 600; res2=$?
check_permissions "/boot/grub2/user.cfg" 600; res3=$?

# Consider only actual permission issues, not missing files
if [[ $res1 -eq 1 || $res2 -eq 1 || $res3 -eq 1 ]]; then
    echo -e "\n⚠️  One or more GRUB bootloader files are misconfigured."
    read -rp "Would you like to automatically fix them? (Y/n): " response
    case "$response" in
        [Yy]* | "") fix_permissions ;;
        *) echo "❌ Remediation skipped by administrator. Exiting."; exit 1 ;;
    esac
else
    echo "✅ All existing GRUB bootloader files are properly configured."
fi

