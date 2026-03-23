# ❄️ NixOS Configuration Hub (Hawi Homestead)

Personal NixOS Flake configuration for the **Lenovo** (Primary) and **HP** (Portable) machines.

---

## 🚀 Quick Usage
- **Rebuild System:** `nrf` (alias for `sudo nixos-rebuild switch --flake .#hostname`)
- **Backups:** `backup` (launches interactive `backup_menu.sh`)
- **Edit Secrets:** `secrets` (opens SOPS-nix yaml)

## 🛠 Maintenance & Syncing
Because `/etc/nixos` is owned by `root`, use the **"Permission Sandwich"** to sync with GitHub:
1. **Claim:** `sudo chown -R mike:users /etc/nixos`
2. **Sync:** `git pull` or `git push origin master`
3. **Lock:** `sudo chown -R root:root /etc/nixos`

> **Note:** Always run `backup_menu.sh` as sudo (this is handled by the `backup` alias).

---

## 📦 System Architecture
- **Flake Based:** Managed via `flake.nix` in the root.
- **Secrets:** Encrypted via **SOPS-Nix** (Age key required for decryption).
- **Backups:** **BorgBackup** managed by systemd jobs (`modules/borg-backup.nix`).
- **Portability:** `backup_menu.sh` uses `$SCRIPT_DIR` and `$(hostname)` to work across both machines.

## 💻 Hardware Specifics
- **Lenovo:** Remote Borg Target: `192.168.79.72`.
- **HP:** Portable unit. Requires `network-online.target` for automated backup success.

---

## 🔍 Troubleshooting & History
- **View Logs:** Use Option 5 in the `backup` menu to see `journalctl` entries.
- **Search Logic:** Technical deep-dives are preserved in Git commits.
  - Search: `git log --grep="keyword"`
  - View Code + Notes: `git log -p`

## 📅 Significant Changes
- **2026-03-16:** Fixed Systemd `unitConfig` warnings and integrated logs into menu.
- **2026-03-15:** Refactored `backup_menu.sh` for hardware-agnostic path resolution.
- **2026-03-06:** Initial secrets implementation via SOPS-Nix.

## ⌨️ Common Aliases
These shortcuts are defined in `modules/scripts.nix`:
## ⌨️ Common Aliases
* **`nrf`** — Rebuild system: `sudo nixos-rebuild switch --flake .#hostname`
* **`backup`** — Launch interactive Borg backup & log menu
* **`notes`** — View this README (formatted via Glow)
* **`secrets`** — Edit encrypted SOPS-nix secrets
* **`edscripts`** — Quickly edit the system aliases and scripts file.


## Recent Updates - 2026-03-22
- Successfully integrated Niri compositor using Flake inputs.
- Resolved Nvidia Wayland cursor issues and build-time test failures.
- Terminal: Foot configured with Wayland-native support.

### Niri Quick-Start Keybinds
| Action | Shortcut |
| :--- | :--- |
| **Terminal** | Mod + T |
| **Launcher** | Mod + D |
| **Close** | Mod + Q |
| **Move** | Mod + Left/Right |
| **Exit** | Mod + Shift + E |

