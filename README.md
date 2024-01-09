## mailcow importer bash script for migrations from older versions.


When coming from older versions of mailcow which are problematic to update via update.sh you can use this workaround to import all emails to a new mailcos-installation:


- install the newest mailcow version: https://docs.mailcow.email/de/i_u_m/i_u_m_install/
- recreate all domains and users manualy (todo: create script to do this from maildir via API)
- rsync only the maildir from old installation:

```
rsync -aHhP --numeric-ids --delete /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/ root@host:/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data
```


- use the importer.sh script to import all emails to the corresponding email-address directly in the container.