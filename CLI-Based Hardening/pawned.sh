#!/bin/bash

# Prompt the user for a password input
echo -ne "Enter the password to check if it is compromised: "
read -s candidate_password
echo ""  # To add a newline after the password input

# Check if the password is provided
if [ -z "$candidate_password" ]; then
    echo "You must enter a password."
    exit 1
fi

echo "Candidate password: $candidate_password"

# Generate SHA-1 hash of the password
full_hash=$(echo -n "$candidate_password" | sha1sum | awk '{print $1}')

# Extract prefix (first 5 characters) and suffix (remaining characters)
prefix=${full_hash:0:5}
suffix=${full_hash:5}

# Query the Have I Been Pwned API with the first 5 characters
response=$(curl -s https://api.pwnedpasswords.com/range/$prefix)

# Check if the suffix appears in the response
if echo "$response" | grep -iq "$suffix"; then
    echo "⚠️ Candidate password is compromised! Choose a stronger one."
else
    echo "✅ Candidate password is safe to use."
fi

