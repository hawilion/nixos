#!/usr/bin/env bash
# ~/bin/borg-menu-sudo.sh
# Desktop-friendly wrapper to run borg-menu.sh with sudo

set -euo pipefail

# Prompt once for sudo at the start
sudo -v

# Run your borg-menu.sh script with sudo
sudo /etc/nixos/borg-menu.sh

# Optionally, you could refresh the sudo timestamp after exit, but not needed
