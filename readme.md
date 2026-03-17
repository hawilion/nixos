# NixOS Configuration Hub

## Project Status: Portability
This repository manages system configuration and backup logic for both the Lenovo and HP machines.

## Key Modules
- **`modules/scripts.nix`**: Contains system-wide aliases (e.g., `nrf` for rebuilds).
- **`modules/borg-backup.nix`**: Declarative backup jobs managed by systemd.
- **`backup_menu.sh`**: Portable wrapper for Borg backups. Uses `SCRIPT_DIR` resolution for machine-agnostic execution.

## Setup Guide (For New Hardware)
1. **Clone Repo**: `git clone <your-repo-url> /etc/nixos`
2. **Setup Secrets**: Ensure your Age key is present for SOPS-Nix decryption.
3. **Apply Config**: `sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)`
4. **Permissions**: Run `chmod +x /etc/nixos/backup_menu.sh`

## Changelog
- **2026-03-15**: Refactor `backup_menu.sh` to use `$SCRIPT_DIR` for hardware portability.
- **2026-03-06**: Initial secrets implementation via SOPS-Nix.
