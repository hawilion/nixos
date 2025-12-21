#!/usr/bin/env bash
set -euo pipefail

REPO="ssh://mike@nixos-server/mnt/backupdisk/borg/hp"   # adjust per machine
HOSTNAME=$(hostname -s)
ARCHIVE="${HOSTNAME}-$(date +%F-%H%M%S)"
EXCLUDES="/root/borg-excludes.txt"
LOGFILE="/var/log/borg-backup.log"

export BORG_PASSPHRASE="$(cat /root/.borg-passphrase)"  # passphrase file

{
    echo "============================="
    echo "Backup started at $(date)"
    echo "Archive: $ARCHIVE"
    echo "Repo: $REPO"
    echo "============================="

    borg create \
        --verbose \
        --filter E \
        --list \
        --stats \
        --show-rc \
        --exclude-from "$EXCLUDES" \
        "$REPO::$ARCHIVE" \
        /

    echo "Pruning old backups..."
    borg prune -v --list "$REPO" \
        --keep-daily=7 \
        --keep-weekly=4 \
        --keep-monthly=6

    echo "Compacting repo..."
    borg compact "$REPO"

    echo "Backup finished at $(date)"
    echo "============================="
} 2>&1 | tee -a "$LOGFILE"
