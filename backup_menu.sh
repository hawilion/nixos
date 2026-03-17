#!/usr/bin/env bash

# Get the directory where the script is located, even if called via symlink
# See README.md or Git log for full technical breakdown.
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

#!nix-shell -i bash -p borgbackup rsync

# Now you can use $SCRIPT_DIR to find your files
# Example: source "$SCRIPT_DIR/my_secrets.sh"

# Ensure we have root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use: sudo $0"
    exit 1
fi

# --- Configuration ---
# Use the same repo path as your NixOS module
REPO="mike@192.168.79.72:/mnt/backupdisk/borg/lenovo"

show_menu() {
    echo "=========================================="
    echo "    NIXOS FLAKE SYSTEM BACKUP (HAWI)      "
    echo "=========================================="
    echo "1) Trigger Manual Backup (via Systemd)"
    echo "2) List Archives"
    echo "3) Repo Info & Deduplication Stats"
    echo "4) Check Last 3 Backups"
    echo "5) Check Journal"
    echo "q) Quit"
    echo "=========================================="
    read -p "Select: " choice
}

while true; do
    show_menu
    case $choice in
        1)
            echo "Starting managed backup job..."
            systemctl start "borgbackup-job-$(hostname)"
            echo "Job initiated. Use option 5 to check status."
            read -p "Press enter to return to menu..."
            ;;
        2)  
            borg list "$REPO"  
            read -p "Press enter to return to menu..."
            ;;
        3)  
            borg info "$REPO"  
            read -p "Press enter to return to menu..."
            ;;
        4)  
            echo "Fetching latest 3 archives..."
            borg list "$REPO" --last 3  
            read -p "Press enter to continue..."  
            ;;
        5)
            echo "--- Latest 20 Backup Log Entries ---"
            journalctl -u "borgbackup-job-$(hostname)" -n 20 --no-hostname
            echo "------------------------------------"
            read -p "Press enter to return to menu..."
            ;;
        q) exit 0 ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done
