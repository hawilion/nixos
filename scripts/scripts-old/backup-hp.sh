#!/usr/bin/env bash
set -euo pipefail

export BORG_PASSCOMMAND="/root/bin/get-borg-pass.sh"

/run/current-system/sw/bin/borg create --verbose --stats --exclude-from /etc/nixos/backup-excludes.txt ssh://mike@nixos-server/mnt/backupdisk/borg/hp::hp-$(date +%Y-%m-%d_%H-%M-%S) /etc/nixos /home/mike
