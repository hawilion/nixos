#!/usr/bin/env bash
set -euo pipefail

# --- User-level configuration ---
SOPS_USE_AGE=1
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"
SECRETS_FILE="/etc/nixos/secrets/secrets.yaml"

echo "🔐 Decrypting Borg passphrase..."
BORG_PASSPHRASE="$(
  SOPS_USE_AGE=$SOPS_USE_AGE \
  SOPS_AGE_KEY_FILE=$SOPS_AGE_KEY_FILE \
  sops -d --extract '["borg-passphrase"]' "$SECRETS_FILE"
)"

if [[ -z "$BORG_PASSPHRASE" ]]; then
  echo "❌ Failed to load Borg passphrase."
  exit 1
fi

# --- Local repo path ---
TEMP_REPO="/etc/nixos/temp-restore/nixos-backups-manual"
mkdir -p "$TEMP_REPO"

# Initialize repo if missing
if [ ! -f "$TEMP_REPO/config" ]; then
  echo "⚙ Initializing Borg repo at $TEMP_REPO..."
  BORG_PASSPHRASE="$BORG_PASSPHRASE" borg init --encryption=repokey "$TEMP_REPO"
fi

# --- Archive name ---
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE="nixos-${TIMESTAMP}"

echo "📦 Backing up /etc/nixos to ${TEMP_REPO}::${ARCHIVE}"
BORG_PASSPHRASE="$BORG_PASSPHRASE" \
  borg create --verbose --stats --progress \
  "${TEMP_REPO}::${ARCHIVE}" /etc/nixos

echo "✅ Manual backup complete: ${ARCHIVE}"
