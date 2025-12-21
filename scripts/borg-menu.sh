#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------
# CONFIG
# -----------------------------------------------------------
EXCLUDE_FILE="/etc/nixos/backup-excludes.txt"
LOCAL_BACKUP_DIR="/etc/nixos/backups"

# -----------------------------------------------------------
# Client configuration
# -----------------------------------------------------------
declare -A CLIENT_REPO
declare -A CLIENT_PATHS

CLIENT_REPO[hp]="ssh://mike@192.168.79.72/mnt/backupdisk/borg/hp"
CLIENT_PATHS[hp]="/home/mike /etc/nixos"

CLIENT_REPO[nixosServer]="/mnt/backupdisk/borg/nixos-server"
CLIENT_PATHS[nixosServer]="/srv /var/lib /etc/nixos"

CLIENTS=("hp" "nixosServer")

# -----------------------------------------------------------
# BORG SSH & passphrase
# -----------------------------------------------------------
BORG_RSH='ssh -i /root/.ssh/borg_backup_key -o StrictHostKeyChecking=no'

if command -v get-borg-pass >/dev/null 2>&1; then
    BORG_PASSCOMMAND="get-borg-pass"
else
    echo "⚠ get-borg-pass script not found; Borg may ask for passphrase."
    BORG_PASSCOMMAND=""
fi

# -----------------------------------------------------------
# Ensure local backup dir exists
# -----------------------------------------------------------
sudo mkdir -p "$LOCAL_BACKUP_DIR"

# -----------------------------------------------------------
# Helper function to run borg as root
# -----------------------------------------------------------
run_borg() {
    sudo BORG_RSH="$BORG_RSH" borg "$@"
}

# -----------------------------------------------------------
# MAIN MENU
# -----------------------------------------------------------
while true; do
    echo
    echo "============== NixOS Backup Menu ==============="
    idx=1
    declare -A client_map
    for client in "${CLIENTS[@]}"; do
        echo "$idx) Backup client: $client"
        client_map[$idx]="$client"
        ((idx++))
    done
    echo "$idx) List completed backups"
    list_option=$idx
    echo "0) Exit"
    echo "==============================================="
    read -rp "Choose an option: " choice

    if [[ "$choice" == "0" ]]; then
        echo "Goodbye."
        exit 0
    fi

    # Option: list completed backups
    if [[ "$choice" == "$list_option" ]]; then
        echo "📚 Completed backups for all clients:"
        for client in "${CLIENTS[@]}"; do
            echo
            echo "=== $client ==="
            CLIENT_REPO_VAL="${CLIENT_REPO[$client]}"
            run_borg list "$CLIENT_REPO_VAL" --last 10 || echo "No backups found."
        done
        continue
    fi

    CLIENT_NAME="${client_map[$choice]}"
    if [[ -z "$CLIENT_NAME" ]]; then
        echo "❌ Invalid choice."
        continue
    fi

    echo "📡 Creating manual Borg backup for client: $CLIENT_NAME..."

    CLIENT_REPO_VAL="${CLIENT_REPO[$CLIENT_NAME]}"
    CLIENT_PATHS_VAL="${CLIENT_PATHS[$CLIENT_NAME]}"

    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    ARCHIVE_NAME="${CLIENT_NAME}-backup-${TIMESTAMP}"

    echo "Using repo: $CLIENT_REPO_VAL"
    echo "Backing up paths:"
    for path in $CLIENT_PATHS_VAL; do
        echo "  $path"
    done

    # --- Print summary of excluded paths ---
    if [[ -f "$EXCLUDE_FILE" ]]; then
        echo
        echo "📌 Excluding the following paths (from $EXCLUDE_FILE):"
        while read -r line; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$line" ]] && continue
            echo "  $line"
        done < "$EXCLUDE_FILE"
        echo
    fi

    # --- Set Borg passphrase safely ---
    if [[ -n "$BORG_PASSCOMMAND" ]]; then
        export BORG_PASSPHRASE="$($BORG_PASSCOMMAND "$CLIENT_NAME")"
    else
        export BORG_PASSPHRASE=""
    fi

    # Create the backup
    run_borg create \
        --verbose --stats --compression zstd \
        --exclude-from "$EXCLUDE_FILE" \
        "$CLIENT_REPO_VAL::$ARCHIVE_NAME" \
        $CLIENT_PATHS_VAL

    echo "✅ Backup complete: $ARCHIVE_NAME"

    # Prune old backups using the same retention rules as automated jobs
    echo "🗑️ Pruning old backups..."
    run_borg prune \
        --keep-last 7 \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 6 \
        "$CLIENT_REPO_VAL"

    echo "✅ Pruning complete for $CLIENT_NAME"

done
