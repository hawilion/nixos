#!/usr/bin/env bash
# borg-menu.sh - unified menu for local and remote Borg backups
set -euo pipefail

# --- CONFIG ---
BORG_REPO_HP="ssh://mike@nixos-server//mnt/backupdisk/borg/hp"
BORG_REPO_SERVER="ssh://mike@nixos-server//mnt/backupdisk/borg/nixos-server"
BORG_RSH='ssh -i /root/.ssh/borg_backup_key -o StrictHostKeyChecking=no'
EXCLUDE_FILE="/etc/nixos/backup-excludes.txt"

# Local repository for /etc/nixos snapshots
LOCAL_NIXOS_REPO="/root/temp-restore/nixos-backups"
TEMP_RESTORE_DIR="/root/temp-restore/restore"

# --- SOPS / BORG PASSPHRASE HANDLING ---
SOPS_KEY="/home/mike/.config/sops/age/identity.txt"
SECRETS_FILE="/etc/nixos/secrets/secrets.yaml"

if [ -f "$SECRETS_FILE" ]; then
    export SOPS_AGE_KEY_FILE="$SOPS_KEY"
    export SOPS_USE_AGE=1

    # Extract Borg passphrase from SOPS secrets
    export BORG_PASSCOMMAND="sops -d $SECRETS_FILE | grep '^borg-passphrase:' | awk '{print \$2}' | tr -d '\"'"
else
    echo "⚠ Secrets file not found: $SECRETS_FILE"
    echo "You may be prompted for a Borg passphrase manually."
fi

# --- SUDO CREDENTIALS CACHE ---
# Prompt for sudo once and keep alive
if [ "$EUID" -ne 0 ]; then
    echo "🔐 Caching sudo credentials for Borg operations..."
    sudo -v
    # Background keep-alive
    ( while true; do sleep 60; sudo -n true 2>/dev/null || exit; done ) &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID' EXIT
fi

# --- ENSURE LOCAL REPO EXISTS ---
sudo mkdir -p "$LOCAL_NIXOS_REPO"
if ! sudo borg info "$LOCAL_NIXOS_REPO" &>/dev/null; then
    echo "Initializing local /etc/nixos repository..."
    sudo borg init --encryption=repokey "$LOCAL_NIXOS_REPO"
fi

# --- MAIN MENU LOOP ---
while true; do
    echo
    echo "================ Borg Backup Menu ================"
    echo "1) Backup HP client (remote)"
    echo "2) Backup NixOS server client (remote)"
    echo "3) Manual local /etc/nixos snapshot"
    echo "4) List all remote backups"
    echo "5) Restore local /etc/nixos snapshot (latest or chosen)"
    echo "6) Prune old local snapshots (keep 5)"
    echo "7) Check repository integrity"
    echo "0) Exit"
    echo "================================================"
    read -rp "Choose an option: " choice

    run_borg() {
        # Wrapper to run borg via sudo only once, using BORG_PASSCOMMAND
        sudo borg "$@"
    }

    case "$choice" in
        1)
            archive="hp-$(date +%Y-%m-%d_%H-%M-%S)"
            echo "Creating remote HP backup..."
            run_borg create --exclude-from "$EXCLUDE_FILE" --compression zstd \
                "$BORG_REPO_HP::$archive" /etc/nixos /home/mike
            echo "✅ HP backup completed: $archive"
            ;;
        2)
            archive="nixos-server-$(date +%Y-%m-%d_%H-%M-%S)"
            echo "Creating remote NixOS server backup..."
            run_borg create --exclude-from "$EXCLUDE_FILE" --compression zstd \
                "$BORG_REPO_SERVER::$archive" /etc/nixos /home /var/lib
            echo "✅ NixOS server backup completed: $archive"
            ;;
        3)
            archive="nixos-$(date +%Y-%m-%d_%H-%M-%S)"
            echo "Creating local snapshot of /etc/nixos..."
            run_borg create --compression zstd "$LOCAL_NIXOS_REPO::$archive" /etc/nixos
            echo "✅ Local snapshot created: $archive"
            ;;
        4)
            echo "Remote HP archives:"
            run_borg list "$BORG_REPO_HP" || echo "No HP backups."
            echo
            echo "Remote NixOS server archives:"
            run_borg list "$BORG_REPO_SERVER" || echo "No server backups."
            ;;
        5)
            sudo mkdir -p "$TEMP_RESTORE_DIR"
            echo "Available local snapshots:"
            archives=($(run_borg list "$LOCAL_NIXOS_REPO" --short || true))
            if [ ${#archives[@]} -eq 0 ]; then
                echo "No local snapshots available."
                continue
            fi
            printf '%s\n' "${archives[@]}"
            read -rp "Enter archive name (or press Enter for latest): " archive
            if [ -z "$archive" ]; then
                archive="${archives[-1]}"
                echo "Restoring latest: $archive"
            fi
            echo "Restoring snapshot..."
            sudo rm -rf "$TEMP_RESTORE_DIR"/*
            run_borg extract "$LOCAL_NIXOS_REPO::$archive"
            echo "✅ Restored to $TEMP_RESTORE_DIR"
            ;;
        6)
            echo "Pruning local snapshots (keeping 5 latest)..."
            run_borg prune -v --list "$LOCAL_NIXOS_REPO" --keep-last=5 || true
            echo "✅ Local prune complete."
            ;;
        7)
            echo "Checking integrity of local and remote repos..."
            run_borg check "$LOCAL_NIXOS_REPO" || true
            run_borg check "$BORG_REPO_HP" || true
            run_borg check "$BORG_REPO_SERVER" || true
            echo "✅ Integrity check complete."
            ;;
        0)
            echo "Exiting menu."
            break
            ;;
        *)
            echo "❌ Invalid option."
            ;;
    esac
done
