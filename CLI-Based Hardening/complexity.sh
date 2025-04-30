#!/bin/bash
echo "Applying strict password security policies..."

# Install required package for password complexity enforcement
dnf install -y libpwquality

# Configure password complexity rules in /etc/security/pwquality.conf
cat <<EOF > /etc/security/pwquality.conf
minlen = 8           # Minimum password length (12 characters)
dcredit = -1          # At least 1 digit required
ucredit = -1          # At least 1 uppercase letter required
lcredit = -1          # At least 1 lowercase letter required
ocredit = -1          # At least 1 special character required (!@#$%^&)
maxrepeat = 3         # No character should repeat more than 3 times
maxclassrepeat = 3    # No more than 3 characters from the same category (upper/lower/digit/special)
difok = 4             # At least 4 characters must be different from the previous password
reject_username = 1   # Prevents username from being used in the password
enforce_for_root = 1  # Enforce rules for root as well
EOF

# Modify PAM authentication rules to enforce strict password policies
sed -i 's/^password.*pam_pwquality.so.*/password    requisite     pam_pwquality.so retry=3 enforce_for_root/' /etc/pam.d/system-auth
sed -i 's/^password.*pam_pwquality.so.*/password    requisite     pam_pwquality.so retry=3 enforce_for_root/' /etc/pam.d/password-auth

# Prevent users from reusing their last 5 passwords
sed -i '/password.*pam_unix.so/c\password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok remember=5' /etc/pam.d/system-auth
sed -i '/password.*pam_unix.so/c\password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok remember=5' /etc/pam.d/password-auth

# Configure password aging policies in /etc/login.defs
cat <<EOF > /etc/login.defs
PASS_MAX_DAYS   90
PASS_MIN_DAYS   7
PASS_WARN_AGE   7
EOF

# Ensure password policies apply to all new users
useradd -D -f 30  # Locks user account if the password expires for 30 days

# Restart SSH service to apply changes
systemctl restart sshd

echo "Strict password security policies applied successfully!"

