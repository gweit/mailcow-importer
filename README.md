## mailcow importer bash script for migrations from older versions.
&nbsp;
When coming from older versions of mailcow which are problematic to update via update.sh you can use this workaround to import all emails to a new mailcos-installation:  
&nbsp;
- install the newest mailcow version: https://docs.mailcow.email/de/i_u_m/i_u_m_install/
- recreate all domains and users manualy (todo: create script to do this from maildir via API)
- rsync only the maildir from old installation:
&nbsp;
```bash
rsync -aHhP --numeric-ids --delete /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/ root@host:/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data
```
&nbsp;
- use the importer.sh script to import all emails to the corresponding email-address directly in the container:
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

