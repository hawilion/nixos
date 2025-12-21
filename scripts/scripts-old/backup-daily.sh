#!/usr/bin/env bash
set -euo pipefail

# --- Remote repo ---
BORG_REPO="ssh://mike@nixos-server/mnt/backupdisk/borg/hp"
BORG_PASSCOMMAND="/root/bin/get-borg-pass.sh"
BORG_RSH="ssh -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=yes"
PATH=/run/current-system/sw/bin:$PATH

# --- Archive name ---
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE="hp-${TIMESTAMP}"

echo "📦 Starting manual backup to ${BORG_REPO}::${ARCHIVE}..."
borg create --verbose --stats --progress \
  "${BORG_REPO}::${ARCHIVE}" /etc/nixos /home/mike

echo "📦 Pruning old backups..."
borg prune --list "${BORG_REPO}" \
  --keep-daily=7 --keep-weekly=4 --keep-monthly=6 \
  --prefix "hp-"

echo "✅ Backup complete: ${ARCHIVE}"
