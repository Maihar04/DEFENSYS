#!/bin/bash

echo "🔒 [Audit] Checking for unconfined SELinux services..."

# Step 1: Check for unconfined services
unconfined_services=$(ps -eZ | grep unconfined_service_t)

if [[ -z "$unconfined_services" ]]; then
    echo "✅ [Secure] No unconfined services detected. SELinux context is properly configured."
    exit 0
else
    echo -e "\n⚠️  [Warning] Unconfined services found:"
    echo "$unconfined_services"
    echo -e "\n🚨 Services running in 'unconfined_service_t' domain have full DAC-level access."

    # Step 2: Ask administrator
    read -p "🛠️  Do you want to log and investigate these services now? [yes/no]: " admin_input

    if [[ "$admin_input" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
        # Create a log file
        log_file="/var/log/unconfined_services_audit_$(date +%F_%T).log"
        echo "$unconfined_services" > "$log_file"
        echo "📁 Services logged to: $log_file"

        echo -e "\n📝 Please review the log and create/assign SELinux policies as needed."
        echo "You may use tools like 'semanage', 'audit2allow', or 'setsebool' depending on the service."
    else
        echo -e "\n❌ No action was taken. Administrator chose not to investigate now."
        exit 1
    fi
fi



