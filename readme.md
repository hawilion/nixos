# NixOS Configuration Hub

## Project Status: Portability
This repository manages system configuration and backup logic for both the Lenovo and HP machines.

## Key Modules
- **`modules/scripts.nix`**: Contains system-wide aliases (e.g., `nrf` for rebuilds).
- **`modules/borg-backup.nix`**: Declarative backup jobs managed by systemd.
- **`backup_menu.sh`**: Portable wrapper for Borg backups. Uses `SCRIPT_DIR` resolution for machine-agnostic execut>

## Setup Guide (For New Hardware)
1. **Clone Repo**: `git clone git@github.com:hawilion/nixos.git /etc/nixos`  
2. **Setup Secrets**: Ensure your Age key is present for SOPS-Nix decryption.
3. **Apply Config**: `sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)`
4. **Permissions**: Run `chmod +x /etc/nixos/backup_menu.sh`

## Changelog
- **2026-03-15**: Refactor `backup_menu.sh` to use `$SCRIPT_DIR` for hardware portability.
- **2026-03-06**: Initial secrets implementation via SOPS-Nix.

## ⌨ Common Aliases
- `nrf`: Rebuild the system flake.
- `backup`: Launches the interactive backup menu.
- `secrets`: Opens the sops-nix secrets file for editing.

## 💻 Hardware Notes
### Lenovo
- Primary workstation.
- Backup Target: Remote Borg Repo (`192.168.79.72`).

### HP
- Portable/Homestead machine.
- *Note:* Ensure network-online.target is reached before backup service triggers.
## 🔍 Tips & Tricks
### Searching the History
Since the Git commit messages contain technical deep-dives (like the `SCRIPT_DIR` logic), you can search them easily:
`git log --grep="keyword"`

### View Full Technical Notes
To see the code changes and the detailed notes side-by-side:
`git log -p`
