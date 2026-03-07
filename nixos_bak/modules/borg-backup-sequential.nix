{ config, pkgs, lib, ... }:

let
  cfg = config.services.borgBackupSequential;
in
{
  options.services.borgBackupSequential = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sequential Borg backups for multiple clients";
    };

    clients = lib.mkOption {
      type = with lib.types; attrsOf (attrsOf str);
      default = {};
      description = "Define clients for sequential backup";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      borgbackup
      bash
      coreutils
      sops
      libnotify
    ];

    # Master sequential backup script
        environment.etc."borg-backup-sequential.sh".text = let
      clientNames = builtins.attrNames cfg.clients;
      clientScripts = lib.concatMapStringsSep "\n" (clientName:
        let client = cfg.clients.${clientName};
            paths = lib.concatStringsSep " " client.backupPaths;
            excludes = lib.concatStringsSep " " (map (p: "--exclude ${p}") client.excludePaths or []);
            repo = client.repo;
        in ''
          echo "=== Starting backup for ${clientName} at $(date) ==="
          notify-send "Borg Backup" "Starting backup for ${clientName}..."
          export BORG_PASSPHRASE=$(sops --decrypt --extract '["BORG_PASSPHRASE"]' $HOME/.config/borg/secrets.enc.yaml)

          if ping -c 1 -W 2 "$${repo%%:*}" >/dev/null 2>&1; then
              ARCHIVE_NAME="${clientName}-$(date +'%Y-%m-%d_%H-%M-%S')"
              borg create --stats --compression lz4 "$repo"::"$ARCHIVE_NAME" ${paths} ${excludes}
              borg prune -v --list "$repo" --keep-daily=7 --keep-weekly=4 --keep-monthly=6
              borg compact "$repo"

              notify-send "Borg Backup" "Backup for ${clientName} completed ✅"
              echo "$(date '+%Y-%m-%d %H:%M:%S') | SUCCESS | ${clientName}" >> /var/log/borg-backup-summary.log
          else
              notify-send "Borg Backup" "Backup for ${clientName} skipped ⚠: Server unreachable"
              echo "$(date '+%Y-%m-%d %H:%M:%S') | SKIPPED | ${clientName}" >> /var/log/borg-backup-summary.log
          fi
        ''
      ) clientNames;
    in ''
      #!/usr/bin/env bash
      set -euo pipefail

      ${clientScripts}
    '';

    systemd.services."borg-backup-sequential" = {
      description = "Sequential Borg backup for multiple clients";
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = "/etc/borg-backup-sequential.sh";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.timers."borg-backup-sequential.timer" = {
      description = "Daily sequential Borg backup timer";
      timerConfig.OnCalendar = "*-*-* 02:00:00";
      timerConfig.Persistent = true;
      wantedBy = [ "timers.target" ];
    };
  };
}
