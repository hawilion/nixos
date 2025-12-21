#!/usr/bin/env bash
set -euo pipefail

# 🔐 Decrypt Borg passphrase (requires root to read secrets)
echo "🔐 Decrypting Borg passphrase..."
export BORG_PASSPHRASE="$(sudo sops -d /etc/nixos/secrets/secrets.yaml | yq -r '.borg_passphrase')"

# Use a dedicated SSH key for backup (root-only)
export BORG_RSH="ssh -i /root/.ssh/id_ed25519"

# 🚀 Create a new backup
echo "🚀 Starting manual /etc/nixos backup..."
borg create --stats \
  ssh://mike@nixos-server//mnt/backupdisk/borg/hp::"etc-nixos-$(date +%F_%H-%M)" \
  /etc/nixos

# 🧹 Prune old backups
echo "🧹 Pruning old backups..."
borg prune -v --list ssh://mike@nixos-server//mnt/backupdisk/borg/hp \
  --keep-daily=7 --keep-weekly=4 --keep-monthly=6

echo "✅ Manual backup completed successfully."
