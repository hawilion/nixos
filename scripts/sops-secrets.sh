#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Configuration
# ----------------------------
if [ "$EUID" -eq 0 ]; then
    export SOPS_AGE_KEY_FILE="/home/mike/.config/sops/age/identity.txt"
else
    export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/identity.txt}"
fi
export SOPS_USE_AGE=1

SECRETS_FILE="/etc/nixos/secrets/secrets.yaml"
BORG_PASSFILE="/root/.config/borg/passphrase"

# ----------------------------
# Helper: update borg passphrase
# ----------------------------
update_borg_pass() {
    echo "🔄 Updating Borg passphrase..."
    sudo mkdir -p "$(dirname "$BORG_PASSFILE")"
    sudo SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY_FILE" sops -d "$SECRETS_FILE" \
        | grep '^borg-passphrase:' | awk '{print $2}' | tr -d '"' \
        | sudo tee "$BORG_PASSFILE" >/dev/null
    sudo chmod 600 "$BORG_PASSFILE"
    echo "✅ Borg passphrase updated at $BORG_PASSFILE"
}

# ----------------------------
# Ensure secrets file exists
# ----------------------------
if [ ! -f "$SECRETS_FILE" ]; then
    echo "🔐 Secrets file not found, creating a new one..."
    sudo mkdir -p "$(dirname "$SECRETS_FILE")"
    AGE_PUBLIC=$(sudo age-keygen -y -i "$SOPS_AGE_KEY_FILE")
    sudo tee "$SECRETS_FILE" >/dev/null <<EOF
borg-passphrase: ""
# add other secrets below
EOF
    sudo sops --age "$AGE_PUBLIC" -e "$SECRETS_FILE" | sudo tee "$SECRETS_FILE" >/dev/null
    echo "✅ New secrets file created at $SECRETS_FILE"
    update_borg_pass
fi

# ----------------------------
# Menu functions
# ----------------------------
menu() {
    echo
    echo "=============================="
    echo "   SOPS Secrets Helper Menu   "
    echo "=============================="
    echo "1) View decrypted secrets"
    echo "2) Edit secrets"
    echo "3) Add a new secret key/value"
    echo "4) Force refresh Borg passphrase"
    echo "5) Exit"
    echo "=============================="
    read -rp "Select an option (1–5): " choice
}

add_secret() {
    read -rp "Enter the key name: " key
    read -rp "Enter the value: " value

    tmpfile=$(mktemp)
    sudo SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY_FILE" sops -d "$SECRETS_FILE" > "$tmpfile"
    echo "$key: \"$value\"" | sudo tee -a "$tmpfile" >/dev/null

    AGE_PUBLIC=$(sudo age-keygen -y -i "$SOPS_AGE_KEY_FILE")
    sudo sops --age "$AGE_PUBLIC" -e "$tmpfile" | sudo tee "$SECRETS_FILE" >/dev/null
    rm "$tmpfile"

    echo "✅ Secret '$key' added and encrypted."
    update_borg_pass
}

# ----------------------------
# Main loop
# ----------------------------
while true; do
    menu
    case "$choice" in
        1)
            echo "🔑 Viewing decrypted secrets..."
            sudo SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY_FILE" sops -d "$SECRETS_FILE"
            ;;
        2)
            echo "✏ Editing secrets..."
            sudo SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY_FILE" sops "$SECRETS_FILE"
            update_borg_pass
            ;;
        3)
            add_secret
            ;;
        4)
            update_borg_pass
            ;;
        5)
            echo "👋 Exiting."
            exit 0
            ;;
        *)
            echo "❌ Invalid option, please select 1–5."
            ;;
    esac
done
