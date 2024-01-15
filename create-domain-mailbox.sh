#!/bin/bash

# Mailcow API details
API_KEY="your-mailcow-api-key"
MAILCOW_URL="https://your-mailcow-url/api/v1"

# Path to the vmail directory
VMAIL_DIR="/var/vmail"

# Function to create a domain in Mailcow
create_domain() {
    local domain=$1
    curl -s -X POST "${MAILCOW_URL}/add/domain" \
         -H "Content-Type: application/json" \
         -H "X-API-Key: ${API_KEY}" \
         --data-raw "{\"domain\":\"${domain}\"}"
}

# Function to create a mailbox in Mailcow
create_mailbox() {
    local domain=$1
    local user=$2
    local password="defaultPassword" # Set a default or generate a password
    curl -s -X POST "${MAILCOW_URL}/add/mailbox" \
         -H "Content-Type: application/json" \
         -H "X-API-Key: ${API_KEY}" \
         --data-raw "{\"local_part\":\"${user}\",\"domain\":\"${domain}\",\"password\":\"${password}\"}"
}

# Read domains and mailboxes from the vmail directory
for domain_dir in "${VMAIL_DIR}"/*; do
    if [ -d "${domain_dir}" ]; then
        domain=$(basename "${domain_dir}")
        echo "Creating domain: ${domain}"
        create_domain "${domain}"

        for user_dir in "${domain_dir}"/*; do
            if [ -d "${user_dir}" ]; then
                user=$(basename "${user_dir}")
                echo "Creating mailbox: ${user}@${domain}"
                create_mailbox "${domain}" "${user}"
            fi
        done
    fi
done
