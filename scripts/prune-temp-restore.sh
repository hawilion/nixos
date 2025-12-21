#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/etc/nixos/logs/prune-temp-restore.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo "🧹 $(date '+%F %T') - Starting temp restore cleanup..." >> "$LOG_FILE"

# Delete files/folders older than 3 days
find /etc/nixos/temp-restore -mindepth 1 -mtime +3 -exec rm -rf {} + 2>>"$LOG_FILE"

echo "✅ $(date '+%F %T') - Cleanup complete." >> "$LOG_FILE"

