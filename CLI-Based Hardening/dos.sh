#!/bin/bash

#===============================
# System Hardening Script: Kernel Parameter Tuning
#===============================

CONFIG_FILE="/etc/sysctl.d/99-network-hardening.conf"

echo "Creating sysctl configuration for network hardening..."

# Create the sysctl hardening file
cat <<EOF > "$CONFIG_FILE"
# Protect against SYN flood
net.ipv4.tcp_syncookies = 1

# Increase SYN backlog to handle more half-open connections
net.ipv4.tcp_max_syn_backlog = 4096

# Reduce SYN-ACK retries to mitigate SYN flood amplification
net.ipv4.tcp_synack_retries = 2

# Ignore ICMP echo requests sent to broadcast addresses
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore bogus ICMP error responses
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Enable reverse path filtering to prevent IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Log suspicious (martian) packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Disable source routed packets
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
EOF

# Apply the new settings
echo "Applying sysctl settings..."
sysctl --system

echo "Network hardening via sysctl completed."


