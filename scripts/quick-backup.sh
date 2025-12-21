#!/usr/bin/env bash
set -euo pipefail

# Detect the real user's home (so backup doesn't go to /root/Desktop)
REAL_USER_HOME=$(getent passwd mike | cut -d: -f6)

DEST_BASE="$REAL_USER_HOME/Desktop/quick-backups"

# Ask user for optional note
read -rp "Optional note for backup name (press Enter for none): " NOTE

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_NAME="etc-nixos-backup-${TIMESTAMP}"

# If a note was entered, sanitize and append it
if [[ -n "${NOTE}" ]]; then
    SAFE_NOTE=$(echo "$NOTE" | tr -cd 'A-Za-z0-9_-')
    BACKUP_NAME="${BACKUP_NAME}-${SAFE_NOTE}"
fi

DEST_DIR="${DEST_BASE}/${BACKUP_NAME}"
mkdir -p "$DEST_DIR"

echo "📦 Creating quick local config backup to: $DEST_DIR"

# Items to back up
ITEMS=(
    "/etc/nixos/configuration.nix"
    "/etc/nixos/hardware-configuration.nix"
    "/etc/nixos/flake.nix"
    "/etc/nixos/flake.lock"
    "/etc/nixos/clients"
    "/etc/nixos/modules"
    "/etc/nixos/scripts"
    "/etc/nixos/secrets"
)

# Copy each item if it exists
for item in "${ITEMS[@]}"; do
    if [[ -e "$item" ]]; then
        rsync -a "$item" "$DEST_DIR/"
    else
        echo "⚠ Skipping missing item: $item"
    fi
done

echo "✅ Quick backup completed!"
echo "📁 Location: $DEST_DIR"
