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
