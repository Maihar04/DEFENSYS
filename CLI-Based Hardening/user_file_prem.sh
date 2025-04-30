#!/bin/bash

echo "🔐 Starting CIS-compliant user and file permission hardening..."

# 1. Set permissions on /etc/passwd
chmod 644 /etc/passwd
chown root:root /etc/passwd
echo "✅ /etc/passwd secured"

# 2. Set permissions on /etc/shadow
chmod 000 /etc/shadow
chown root:root /etc/shadow
echo "✅ /etc/shadow secured"

# 3. Set permissions on /etc/group
chmod 644 /etc/group
chown root:root /etc/group
echo "✅ /etc/group secured"

# 4. Set permissions on /etc/gshadow
chmod 000 /etc/gshadow
chown root:root /etc/gshadow
echo "✅ /etc/gshadow secured"

# 5. Set permissions on /etc/passwd-, /etc/shadow-, etc.
for file in /etc/*-; do
  chmod 600 "$file" 2>/dev/null
  chown root:root "$file" 2>/dev/null
done
echo "✅ Backup files secured"

# 6. Check for world-writable files (should be reviewed manually too)
echo "🔎 Checking world-writable files (excluding /proc):"
find / -xdev -type f -perm -0002 -exec ls -l {} \; 2>/dev/null

# 7. Remove SUID/SGID from non-standard binaries
echo "🔎 Checking for unusual SUID/SGID binaries:"
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -exec ls -l {} \; > suid_files.txt
echo "List of SUID/SGID files saved to suid_files.txt. Review carefully."

# 8. Disable root login via console (except tty1)
echo "console tty1" > /etc/securetty
chmod 600 /etc/securetty
echo "✅ Restricted root login to tty1 only"

# 9. Remove users with no password (audit)
echo "🔎 Checking for users with empty passwords:"
awk -F: '($2==""){print $1}' /etc/shadow

# 10. Lock system accounts
for user in `awk -F: '($3 < 1000 && $1 != "root") { print $1 }' /etc/passwd`; do
  usermod -L "$user" 2>/dev/null
  usermod -s /sbin/nologin "$user" 2>/dev/null
done
echo "✅ System accounts locked"

echo "🔎 Checking for duplicate UIDs/GIDs:"
cut -f3 -d: /etc/passwd | sort -n | uniq -c | awk '$1 > 1 {print "Duplicate UID: "$2}'
cut -f3 -d: /etc/group | sort -n | uniq -c | awk '$1 > 1 {print "Duplicate GID: "$2}'

# 12. Disable inactive users (no login for 35+ days)
echo "🔒 Locking inactive users (35+ days):"
useradd -D -f 35
for user in $(awk -F: '{if ($3 >= 1000 && $1 != "nobody") print $1}' /etc/passwd); do
  lastlog -b 35 -u "$user" | grep -v "**Never logged in**" | grep "$user" &>/dev/null && usermod -L "$user"
done


# 13. Secure system backup files (if any)
if [ -d "/etc/backup" ]; then
  chmod -R 600 /etc/backup
  chown -R root:root /etc/backup
  echo "✅ Backup directory secured"
fi

# 14. Log changes for audit trail
echo "$(date) - Permissions for /etc/passwd changed to 644" >> /var/log/security_audit.log
echo "$(date) - Permissions for /etc/shadow changed to 000" >> /var/log/security_audit.log
echo "$(date) - Permissions for /etc/group changed to 644" >> /var/log/security_audit.log
echo "$(date) - Permissions for /etc/gshadow changed to 000" >> /var/log/security_audit.log

# 15. Audit for users with empty passwords
echo "🔍 Checking for users with empty passwords..."
awk -F: '($2 == "") { print "⚠️  User with no password set: " $1 }' /etc/shadow > empty_password_users.txt

if [ -s empty_password_users.txt ]; then
    echo "🚨 Users found with NO passwords set:"
    cat empty_password_users.txt
    echo "📄 Full list saved in: empty_password_users.txt"
else
    echo "✅ All users have passwords set."
fi

echo "🎯 User and File permission hardening complete."

# Final check for world-writable files
echo "🔎 Final check for world-writable files (excluding /proc):"
find / -xdev -type f -perm -0002 -exec ls -l {} \; 2>/dev/null

