#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
BORG_REPO="ssh://mike@nixos-server/mnt/backupdisk/borg/hp"
BORG_PASSCOMMAND="/root/bin/get-borg-pass.sh"
PATH=/run/current-system/sw/bin:$PATH

LOCAL_BACKUP_DIR="/root/backups-local"
mkdir -p "$LOCAL_BACKUP_DIR"

# --- Functions ---
backup_home_and_etc() {
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    ARCHIVE="full-${TIMESTAMP}"

    echo "🗄️ Starting FULL backup (home + /etc/nixos)..."
    borg create \
        --stats \
        --compression zstd \
        "$BORG_REPO::$ARCHIVE" \
        /home/mike \
        /etc/nixos

    echo "✅ Full backup completed: $ARCHIVE"
}

backup_nixos_local() {
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    ARCHIVE="nixos-${TIMESTAMP}"
    TARGET="$LOCAL_BACKUP_DIR/$ARCHIVE.tar.gz"

    echo "🗄️ Creating LOCAL backup of /etc/nixos..."
    tar -czf "$TARGET" /etc/nixos
    echo "✅ Local archive saved: $TARGET"
}

restore_home_and_etc() {
    echo "📦 Available backups:"
    borg list "$BORG_REPO"

    read -rp "Enter archive name to restore: " ARCHIVE
    RESTORE_DIR="/root/restore-home-etc-$ARCHIVE"
    mkdir -p "$RESTORE_DIR"

    echo "🗄️ Restoring $ARCHIVE to $RESTORE_DIR ..."
    borg extract "$BORG_REPO::$ARCHIVE" --target "$RESTORE_DIR"
    echo "✅ Restore complete in: $RESTORE_DIR"
}

restore_nixos_local() {
    echo "📦 Local backups:"
    ls -1 "$LOCAL_BACKUP_DIR"

    read -rp "Enter archive filename to restore: " ARCHIVE
    RESTORE_DIR="/root/restore-nixos-local"
    mkdir -p "$RESTORE_DIR"

    echo "🗄️ Restoring local backup..."
    tar -xzf "$LOCAL_BACKUP_DIR/$ARCHIVE" -C "$RESTORE_DIR"
    echo "✅ Restored to: $RESTORE_DIR"
}

view_logs() {
    echo "📜 Last 10 created archives:"
    borg list "$BORG_REPO" | tail -n 10
}

# --- Menu ---
while true; do
    clear
    echo "=========================="
    echo "   Borg Backup Menu"
    echo "=========================="
    echo "1) Manual backup: home + /etc/nixos → LAN Borg server"
    echo "2) Manual LOCAL backup: /etc/nixos only"
    echo "3) Restore home + /etc/nixos"
    echo "4) Restore LOCAL /etc/nixos backup"
    echo "5) View logs (recent backups)"
    echo "6) Quit"
    echo "=========================="
    read -rp "Choose an option: " opt

    case "$opt" in
        1) backup_home_and_etc ;;
        2) backup_nixos_local ;;
        3) restore_home_and_etc ;;
        4) restore_nixos_local ;;
        5) view_logs ;;
        6) exit 0 ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac

    read -rp "Press enter to continue..."
done

