#!/usr/bin/env bash

# --- Configuration ---
# Pointing to your actual flake-based secrets
export SOPS_AGE_KEY_FILE="/home/mike/sops/age/keys.txt"
SECRETS_FILE="/etc/nixos/secrets/lenovo.yaml"
# Decrypt the passphrase using SOPS
export BORG_PASSPHRASE=$(sudo SOPS_AGE_KEY_FILE=$SOPS_AGE_KEY_FILE sops -d --extract '["borg_passphrase"]' $SECRETS_FILE)


REPO="mike@192.168.79.72:/mnt/backupdisk/borg/lenovo"
EXCLUDES="/etc/nixos/backup-excludes.txt"

# What we are protecting
SOURCES=(
    "/etc/nixos"
    "/home/mike/Desktop/Land_Court_2026"
    "/home/mike/.ssh"
    "/home/mike/.config/sops" # Good to keep your SOPS keys backed up too
    "/home/mike/sops"
)

show_menu() {
    echo "=========================================="
    echo "    NIXOS FLAKE SYSTEM BACKUP (HAWI)      "
    echo "=========================================="
    echo "1) Full System + Land Court Sync"
    echo "2) List Archives"
    echo "3) Repo Info & Deduplication Stats"
    echo "q) Quit"
    echo "=========================================="
    read -p "Select: " choice
}

while true; do
    show_menu
    case $choice in
        1)
            echo "Backing up Flake config and Desktop..."
            borg create --stats --progress --compression lz4 \
                --exclude-from "$EXCLUDES" \
                $REPO::"System-$(date +%Y-%m-%d-%H%M)" \
                "${SOURCES[@]}"
            ;;
        2) borg list $REPO ;;
        3) borg info $REPO ;;
        q) exit 0 ;;
    esac
done
