#!/bin/bash
echo "Applying System Integrity & Compliance Hardening..."

# 1. Install essential security tools
echo "Installing essential security tools..."
dnf install -y scap-security-guide openscap-scanner

# 2. Enable Secure Boot Validation (if platform supports it)
echo "Enabling Secure Boot Validation (mokutil)..."
mokutil --enable-validation

# 3. Disable USB Storage (Block USB devices)
echo "Disabling USB storage access..."
echo "install usb_storage /bin/false" >> /etc/modprobe.d/usb.conf

# 4. Apply SELinux in Enforcing Mode
echo "Setting SELinux to Enforcing mode..."
setenforce 1
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

echo "Base System Integrity & Compliance Hardening Applied!"

# 5. Prompt admin to perform compliance scan
read -p "Would you like to perform a system compliance scan now? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo "Listing available compliance profiles..."
    sleep 2
    oscap info /usr/share/xml/scap/ssg/content/ssg-*.xml

    echo ""
    echo "Note: Above are the available security profiles."
    read -p "Enter the exact profile ID you want to use for scanning (e.g., xccdf_org.ssgproject.content_profile_standard): " profile

    # Define report paths
    tmp_report="/tmp/system_compliance_report.html"
    home_report="$HOME/system_compliance_report.html"

    echo "Starting system compliance scan..."
    sudo oscap xccdf eval --profile "$profile" \
        --report "$tmp_report" \
        /usr/share/xml/scap/ssg/content/ssg-*.xml

    if [[ -f "$tmp_report" ]]; then
        echo ""
        echo "Compliance scan completed successfully!"
        echo "Copying report to your home directory for safekeeping..."
        cp "$tmp_report" "$home_report"
        echo "Report available at: $home_report"
        echo ""
        echo "To open the report, run:"
        echo "xdg-open \"$home_report\""
    else
        echo ""
        echo "❌ Compliance scan failed or report not generated."
    fi
else
    echo "Skipping compliance scan as per user choice."
fi

echo ""
echo "✅ System Hardening Completed Successfully!"

