#!/bin/bash

echo " Configuring log rotation for sudo logs..." | tee -a /var/log/hardening.log

# Create logrotate configuration for sudo logs
cat <<EOF > /etc/logrotate.d/sudo
/var/log/sudo.log {
    weekly                  # Rotate logs every week
    rotate 4                # Keep last 4 rotated logs
    compress                # Compress older logs (e.g., sudo.log.1.gz)
    missingok               # Ignore errors if log file is missing
    notifempty              # Do not rotate if the log is empty
    create 0600 root root   # Ensure proper permissions for new log files
}
EOF

echo " Sudo log rotation configured successfully!" | tee -a /var/log/hardening.log

