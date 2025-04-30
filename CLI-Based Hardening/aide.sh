#!/bin/bash

# AIDE Integrity Check Script

GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[1;34m"
NC="\033[0m" # No Color

LOG_DIR="/var/log/aide"
LOG_FILE="$LOG_DIR/aide-check-$(date +%F).log"

# Create log directory if it doesn't exist
sudo mkdir -p "$LOG_DIR"
sudo chmod 700 "$LOG_DIR"

clear
echo -e "${BLUE}🔐 AIDE Integrity Check Script — Linux Hardening${NC}"
echo "---------------------------------------------"

# Check AIDE installation
if ! command -v aide &> /dev/null; then
    echo -e "${RED}[✗] AIDE is not installed.${NC}"
    echo -e "${BLUE}[>] Installing AIDE...${NC}"
    sudo dnf install aide -y
else
    echo -e "${GREEN}[✓] AIDE is already installed.${NC}"
fi

# Initialize if first time
if [ ! -f /var/lib/aide/aide.db.gz ]; then
    echo -e "${BLUE}[>] First time setup: Initializing AIDE database...${NC}"
    sudo aide --init
    sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    echo -e "${GREEN}[✓] AIDE initialized successfully.${NC}"
fi

# Ask user to continue
read -p $'\nDo you want to run an AIDE integrity check now? (y/n): ' answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "\n${BLUE}[>] Running AIDE integrity check...${NC}"
    sudo aide --check | tee "$LOG_FILE"

    # Simple readable summary
    if grep -q "found differences between database and filesystem" "$LOG_FILE"; then
        echo -e "\n${RED}[!] ALERT: Changes detected!${NC}"
    else
        echo -e "\n${GREEN}[✓] System integrity verified. No changes detected.${NC}"
    fi

    echo -e "${BLUE}[i] Full report saved to: $LOG_FILE${NC}"
else
    echo -e "${RED}[x] Skipping AIDE check. Exiting.${NC}"
fi

