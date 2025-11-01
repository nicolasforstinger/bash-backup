# Bash Backup Script

A simple bash script for automated directory backups with retention policy.

## Features
- Creates timestamped compressed backups using `tar`
- Automatic rotation of old backups
- Configurable retention policy
- Validation and error handling

## Usage
```bash
./backup.sh /path/to/directory /path/to/backup number_of_backups_to_keep
```
## Examples
```bash
# Backup home directory, keep last 7 backups
./backup.sh /home/user /mnt/backup 7

# Backup website files, keep last 30 backups  
./backup.sh /var/www/html /media/usb 30

# Backup documents, keep only the last backup
./backup.sh /home/user/Documents /home/user/.bk 1