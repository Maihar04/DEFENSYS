#!/bin/bash

# ============================
# Linux Hardening: Process Audit Script (User-Interactive)
# Author: YourName
# Description: User chooses what process type to audit.
# ============================

LOGFILE="/var/log/process_audit.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "==============================="
echo " Linux Process Audit Menu"
echo "==============================="
echo "1. Find Idle Processes (0.0% CPU Usage)"
echo "2. List Sleeping Processes"
echo "3. List Zombie Processes"
echo "4. Exit"
echo "==============================="

read -p "Enter your choice [1-4]: " choice

echo "[$TIMESTAMP] Process Audit Started" | tee -a "$LOGFILE"
echo "--------------------------------------" | tee -a "$LOGFILE"

case "$choice" in

    1)
        echo -e "\n[1] Idle Processes (0.0% CPU usage):" | tee -a "$LOGFILE"
        printf "%-10s %-10s %-10s %-10s %-10s\n" "PID" "USER" "CPU%" "MEM%" "COMMAND" | tee -a "$LOGFILE"
        ps -eo pid,user,%cpu,%mem,comm --sort=%cpu | awk '$3 == "0.0" {printf "%-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}' | tee -a "$LOGFILE"
        ;;
        
    2)
        echo -e "\n[2] Sleeping Processes (Status: S):" | tee -a "$LOGFILE"
        ps -eo pid,stat,cmd | awk '$2 ~ /^S/ {print $0}' | tee -a "$LOGFILE"
        ;;
        
    3)
        echo -e "\n[3] Zombie Processes (Status: Z):" | tee -a "$LOGFILE"
        ZOMBIE_PROCESSES=$(ps -eo pid,stat,cmd | awk '$2 ~ /^Z/ {print $0}')
        if [ -z "$ZOMBIE_PROCESSES" ]; then
            echo "No zombie processes found." | tee -a "$LOGFILE"
        else
            echo "$ZOMBIE_PROCESSES" | tee -a "$LOGFILE"

            # Ask if user wants to kill them
            read -p "Do you want to attempt killing zombie processes? (y/n): " kill_choice
            if [[ "$kill_choice" == "y" || "$kill_choice" == "Y" ]]; then
                echo -e "\n[4] Attempting to kill zombie processes..." | tee -a "$LOGFILE"
                ZOMBIE_PIDS=$(echo "$ZOMBIE_PROCESSES" | awk '{print $1}')
                for pid in $ZOMBIE_PIDS; do
                    echo "Killing zombie process PID: $pid" | tee -a "$LOGFILE"
                    kill -9 "$pid" 2>>"$LOGFILE"
                done
            else
                echo "Skipping zombie process termination." | tee -a "$LOGFILE"
            fi
        fi
        ;;
        
    4)
        echo "Exiting..."; exit 0 ;;
        
    *)
        echo "Invalid choice! Please select option 1-4."
        ;;
esac

echo -e "\n[$TIMESTAMP] Process Audit Completed" | tee -a "$LOGFILE"

