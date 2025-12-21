#!/usr/bin/env bash
set -euo pipefail

REPO="/mnt/backupdisk/borg/nixos-server"  # adjust per machine
RESTORE_DIR="/root/tmp-restore-etc-nixos"
EXTRACT_PATH="etc/nixos"

export BORG_PASSPHRASE="$(cat /root/.borg-passphrase)"

usage() {
    echo "Usage: $0 <archive-name>"
    echo "List available archives with: borg list $REPO"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

ARCHIVE="$1"

# Clean restore dir
rm -rf "$RESTORE_DIR"
mkdir -p "$RESTORE_DIR"

echo "Restoring $EXTRACT_PATH from $ARCHIVE into $RESTORE_DIR ..."
borg extract \
    --verbose \
    "$REPO::$ARCHIVE" \
    "$EXTRACT_PATH"

# Move restored etc/nixos into restore dir
mv "$EXTRACT_PATH" "$RESTORE_DIR/"

echo "Restore complete."
echo "Files are in: $RESTORE_DIR/nixos"
echo "Compare or copy manually to /etc/nixos when ready."
