#!/bin/bash
# backup.sh - A simple backup creation script

set -e

if ! command -v tar &> /dev/null; then
    echo "✗ tar is not installed" >&2
    exit 1
fi

BACKUP_DIR=$1
BACKUP_PATH=$2
KEEP_COUNT=$3
TIMESTAMP=$(date +%Y%m%d-%H%M)

if [ -z "$BACKUP_DIR" ] || [ -z "$BACKUP_PATH" ] || [ -z "$KEEP_COUNT" ]; then
    echo "Usage:   $0 <source_directory> <backup_destination> <keep_count>"
    echo "Example: $0 /home/user /mnt/backup 7"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "✗ Source directory $BACKUP_DIR does not exist!"  >&2
    exit 1
fi

mkdir -p "$BACKUP_PATH"

BACKUP_NAME="backup-$(basename "$BACKUP_DIR")-$TIMESTAMP.tar.gz"
FULL_BACKUP_PATH="$BACKUP_PATH/$BACKUP_NAME"

echo "Starting backup of $BACKUP_DIR..."
echo "Backup file: $FULL_BACKUP_PATH"

tar -czf "$FULL_BACKUP_PATH" "$BACKUP_DIR" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Backup created successfully: $BACKUP_NAME"
    echo "Checking for old backups to rotate..."
    
    BACKUP_COUNT=$(find "$BACKUP_PATH" -maxdepth 1 -name "backup-$(basename "$BACKUP_DIR")-*.tar.gz" | wc -l)
    
    if [ "$BACKUP_COUNT" -gt "$KEEP_COUNT" ]; then
        REMOVE_COUNT=$((BACKUP_COUNT - KEEP_COUNT))
        echo "Removing $REMOVE_COUNT old backup(s)..."
        
        find "$BACKUP_PATH" -maxdepth 1 -name "backup-$(basename "$BACKUP_DIR")-*.tar.gz" -type f -printf '%T@ %p\n' | \
        sort -n | \
        head -n "$REMOVE_COUNT" | \
        cut -d' ' -f2- | \
        xargs rm -f
        
        echo "✓ Backup rotation completed"
    else
        echo "✓ No rotation needed ($BACKUP_COUNT backups, keeping $KEEP_COUNT)"
    fi
    
else
    echo "✗ Backup failed!" >&2
    exit 1
fi

echo "Backup process completed successfully!"