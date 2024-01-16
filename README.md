## mailcow importer bash script for migrations from older versions.
&nbsp;

When coming from older versions of mailcow which are problematic to update via update.sh you can use this workaround to import all emails to a new mailcos-installation:
&nbsp;

- install the newest mailcow version: https://docs.mailcow.email/de/i_u_m/i_u_m_install/
- recreate all domains and users manualy or via create-domain-mailbox.sh
- rsync only the maildir from old installation:

&nbsp;
```bash
rsync -aHhP --numeric-ids --delete /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/ root@host:/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data
```
&nbsp;
- use the importer.sh script to import all emails to the corresponding email-address directly in the dovecot-container:

&nbsp;
```bash
#!/bin/bash

# Define the parent path of the Maildir
MAILDIR_PARENT="/var/vmail"

# Get all users from doveadm
USERS=$(doveadm user '*')

# Loop through each user
for FULL_USER in $USERS; do
    # Extract domain and username
    DOMAIN=$(echo "$FULL_USER" | cut -d@ -f2)
    USER=$(echo "$FULL_USER" | cut -d@ -f1)

    # Construct the path to the user's Maildir
    USER_MAILDIR="${MAILDIR_PARENT}/${DOMAIN}/${USER}"

    # Check if the Maildir exists
    if [ -d "$USER_MAILDIR" ]; then
        echo "Processing $USER_MAILDIR"

        # Insert your command to import mails from the user's Maildir
        # For example, using doveadm import (adjust as necessary):
        doveadm import -u $FULL_USER maildir:$USER_MAILDIR "" all

        # Replace the above line with your actual command for importing mails.
    else
        echo "Maildir not found for $FULL_USER"
    fi
done
```

&nbsp;
## Update: 15.01.2024
&nbsp;

- added script to create domains and mailboxes from maildir: create-domain-mailbox.sh
&nbsp;
Please pay attention to change the variables to suit your environment.
&nbsp;

```bash
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
```