My personal NixOS configuration for my machines (Lenovo & HP).

Overview
System: NixOS (Unstable/Stable)

y

Backup: Managed via BorgBackup to a remote server.

Secret Management: SOPS-nix.

Usage
To apply changes:
sudo nixos-rebuild switch --flake .#hostname

Directory Structure
modules/: Shared configuration logic.

hosts/: Host-specific settings for each device.

secrets/: Encrypted secrets (via SOPS).
