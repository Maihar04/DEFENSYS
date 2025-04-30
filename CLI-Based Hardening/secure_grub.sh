#!/usr/bin/env bash

# Variables
GRUB_CFG="/boot/grub2/grub.cfg"
USER_CFG="/boot/grub2/user.cfg"
USERNAME="admin"  # Change this to your preferred GRUB username

# Function to check if a password is already set
check_grub_password() {
    if grep -q "GRUB2_PASSWORD=" "$USER_CFG" 2>/dev/null || \
       grep -q "password" "$GRUB_CFG" 2>/dev/null; then
        echo -e "\n✅ Bootloader password is already set.\n"
        exit 0
    fi
}

# Function to prompt user for password
prompt_for_password() {
    echo -e "\n🔒 Enter a new password for GRUB:"
    read -s PASSWORD  # -s hides input
    echo -e "🔒 Confirm password:"
    read -s CONFIRM_PASSWORD

    if [ "$PASSWORD" != "$CONFIRM_PASSWORD" ]; then
        echo -e "\n❌ Passwords do not match. Please try again."
        prompt_for_password
    fi
}

# Function to generate a hashed password
generate_hashed_password() {
    echo -e "$PASSWORD\n$PASSWORD" | grub-mkpasswd-pbkdf2 | awk '/grub.pbkdf2/ {print $NF}'
}

# Function to set GRUB password
set_grub_password() {
    HASHED_PASSWORD=$(generate_hashed_password)

    echo "Setting GRUB2 Bootloader Password..."
    echo "GRUB2_PASSWORD=${HASHED_PASSWORD}" > "$USER_CFG"
    chmod 600 "$USER_CFG"  # Secure the password file

    echo -e "\n✅ Password has been set in $USER_CFG\n"

    # Enforce GRUB password in grub.cfg
    echo -e "\nUpdating GRUB configuration to require authentication...\n"
    echo -e "set superusers=\"${USERNAME}\"\npassword_pbkdf2 ${USERNAME} ${HASHED_PASSWORD}" >> "$GRUB_CFG"
}

# Function to update GRUB configuration
update_grub_config() {
    echo "Updating GRUB2 configuration..."
    grub2-mkconfig -o "$GRUB_CFG"
    echo -e "\n✅ GRUB2 configuration updated successfully.\n"
}

# Main Execution
check_grub_password
prompt_for_password  # Ask for the password before proceeding
set_grub_password
update_grub_config

echo -e "\n🚀 Bootloader password has been enforced successfully!\n"

