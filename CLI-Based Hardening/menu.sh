#!/bin/bash

# Script names and descriptions
scripts=(
  "aide.sh|Integrity check using AIDE to detect file changes"
  "complexity.sh|Checks password complexity policy settings"
  "grub_prem.sh|Validates GRUB file permissions for security"
  "Permit_Empty_pass.sh|Ensures empty password logins are disabled"
  "tuner.sh|System performance tuning and optimization"
  "zombie.sh|Detects and reports zombie processes"
  "compliance2.sh|Runs system compliance checks"
  "log_rotate.sh|Manages and automates log rotation"
  "secure_grub.sh|Hardens GRUB bootloader against tampering"
  "unconfined.sh|Lists unconfined SELinux processes"
  "check_login.sh|Analyzes login logs for suspicious access"
  "dos.sh|Simulates and detects DoS attack vectors"
  "lynis.sh|Performs a security audit using Lynis tool"
  "user_file_prem.sh|Checks user file permission misconfigurations"
  "chrony.sh|Validates Chrony time synchronization setup"
  "pawned.sh|Checks system users against 'Have I Been Pwned'"
  "whitelist.sh|Verifies allowed IPs or services against a whitelist"
)

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"

# Terminal width
term_width=$(tput cols)

center_text() {
  text="$1"
  printf "%*s\n" $(((${#text} + term_width) / 2)) "$text"
}

# Clear screen and display banner
clear
echo -e "${CYAN}"
center_text "=============================================="
center_text "        DEFENSYS LINUX HARDENING"
center_text "=============================================="
echo -e "${RESET}"
sleep 1

# Group Members
echo -e "${YELLOW}"
center_text "Project Group Members:"
center_text "Korukonda Jayavardhan"
center_text "Maihar Kumar Arora"
center_text "Adarsh"
center_text "Manikya Negi"
echo -e "${RESET}"
sleep 2

# Show the menu in a table format
show_menu() {
  echo -e "${YELLOW}\nAvailable Scripts:${RESET}\n"

  printf "${CYAN}%-5s %-25s %-60s${RESET}\n" "No." "Script Name" "Description"
  echo -e "${CYAN}-----------------------------------------------------------------------------------------${RESET}"

  for i in "${!scripts[@]}"; do
    IFS='|' read -r name desc <<< "${scripts[$i]}"
    printf "%-5s %-25s %-60s\n" "$((i+1)))" "$name" "$desc"
  done

  echo -e "\n${CYAN}0) Exit${RESET}"
  echo -e "${CYAN}-----------------------------------------------------------------------------------------${RESET}"
}

# Main Loop
while true; do
  show_menu
  echo -ne "${GREEN}Enter the index number of the script to run: ${RESET}"
  read choice

  if [[ "$choice" == "0" ]]; then
    echo -e "${RED}Exiting. Goodbye!${RESET}"
    break
  elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#scripts[@]} )); then
    IFS='|' read -r script _ <<< "${scripts[$((choice-1))]}"
    echo -e "${CYAN}Running '${script}'...${RESET}"
    chmod +x "$script"
    ./"$script"
    echo -e "${GREEN}Execution complete.${RESET}"
  else
    echo -e "${RED}Invalid input. Please select a valid number.${RESET}"
  fi

  echo -e "\nPress Enter to return to the menu..."
  read
  clear
  echo -e "${CYAN}"
  center_text "=============================================="
  center_text "        DEFENSYS LINUX HARDENING"
  center_text "=============================================="
  echo -e "${RESET}"
  sleep 1
done

