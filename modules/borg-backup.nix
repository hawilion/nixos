{ config, lib, pkgs, ... }:

let
  cfg = config.borgBackup;
in
{
  options.borgBackup = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Borg backup service.";
    };

    clients = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Paths to back up.";
          };
          repo = lib.mkOption {
            type = lib.types.str;
            description = "Repository path.";
          };
          schedule = lib.mkOption {
            type = lib.types.str;
            default = "*-*-* 00:00:00";
            description = "Systemd calendar format for daily backup.";
          };
        };
      });
      default = {};
    };

    passphraseCommand = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Command that prints the Borg passphrase.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ------------------------
    # Systemd services
    # ------------------------
    systemd.services = lib.mapAttrs'
      (clientName: clientCfg: {
        name = "borg-backup-${clientName}";
        value = {
          description = "Borg backup job for ${clientName}";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "borg-backup-${clientName}" ''
              #!${pkgs.bash}/bin/bash
              set -euo pipefail

              # Set the Borg passphrase
              export BORG_PASSPHRASE="$(${cfg.passphraseCommand} ${clientName})"

              # Timestamp for the archive
              TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

              echo "=== Starting backup for ${clientName} at \$TIMESTAMP ==="

              # Run borg create
              ${pkgs.borgbackup}/bin/borg create \
                --verbose --stats --compression zstd \
                ${clientCfg.repo}::"${clientName}-backup-\$TIMESTAMP" \
                ${lib.concatStringsSep " " clientCfg.paths}

              # Prune old backups
              ${pkgs.borgbackup}/bin/borg prune \
                --keep-last 7 --keep-daily 7 --keep-weekly 4 --keep-monthly 6 \
                ${clientCfg.repo}

              echo "=== Backup complete for ${clientName} ==="
            '';
          };

          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
        };
      })
      cfg.clients;

    # ------------------------
    # Systemd timers
    # ------------------------
    systemd.timers = lib.mapAttrs'
      (clientName: clientCfg: {
        name = "borg-backup-${clientName}";
        value = {
          description = "Timer for borg-backup-${clientName}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = clientCfg.schedule;
            Persistent = true;
          };
        };
      })
      cfg.clients;
  };
}
