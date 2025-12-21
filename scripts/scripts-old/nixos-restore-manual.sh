#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
SOPS_USE_AGE=1
SOPS_AGE_KEY_FILE="/home/mike/.config/sops/age/identity.txt"
SECRETS_FILE="/etc/nixos/secrets/secrets.yaml"

# --- Decrypt Borg passphrase as mike (non-root) ---
echo "🔐 Decrypting Borg passphrase..."
BORG_PASSPHRASE="$(
  SOPS_USE_AGE=$SOPS_USE_AGE \
  SOPS_AGE_KEY_FILE=$SOPS_AGE_KEY_FILE \
  sops -d --extract '["borg-passphrase"]' "$SECRETS_FILE"
)"

if [[ -z "$BORG_PASSPHRASE" ]]; then
  echo "❌ Failed to load Borg passphrase from SOPS file."
  exit 1
fi

# --- Directories ---
tempRestore="/etc/nixos/temp-restore"
nixosRepo="${tempRestore}/nixos-backups-manual"
restoreDir="${tempRestore}/restore-etc-nixos-$(date +%Y%m%d_%H%M%S)"

mkdir -p "$restoreDir"

# --- List archives ---
echo "📂 Listing available archives..."
archives=($(sudo BORG_PASSPHRASE="$BORG_PASSPHRASE" borg list --short "$nixosRepo" | sort))

if [ ${#archives[@]} -eq 0 ]; then
    echo "❌ No archives found in $nixosRepo"
    exit 1
fi

echo "=== Available /etc/nixos backups ==="
for a in "${archives[@]}"; do echo "  $a"; done

# --- Ask user for archive ---
read -rp "Enter archive to restore (Enter for latest): " choice
latest="${choice:-${archives[-1]}}"

# --- Restore ---
echo "✅ Selected archive: $latest"
echo "📦 Restoring to: $restoreDir"

cd "$restoreDir"
sudo BORG_PASSPHRASE="$BORG_PASSPHRASE" borg extract "$nixosRepo"::"$latest"

echo "✅ Restore complete."
echo "🗂️ Files are under: $restoreDir"
