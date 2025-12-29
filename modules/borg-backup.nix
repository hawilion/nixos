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
            description = "Repository path (user@ip:/path).";
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
    # Filter: Only create services for the client matching this machine's hostname
    systemd.services = let 
      relevantClients = lib.filterAttrs (n: _: n == config.networking.hostName) cfg.clients;
    in lib.mapAttrs' (clientName: clientCfg: {
      name = "borg-backup-${clientName}";
      value = {
        description = "Borg backup job for ${clientName}";
        serviceConfig = {
          Type = "oneshot";
          User = "mike";        # Vital: Runs as you to access your SSH keys
          Group = "users";
          ExecStart = pkgs.writeShellScript "borg-backup-${clientName}" ''
            #!${pkgs.bash}/bin/bash
            set -euo pipefail

            # Use your specific SSH key
            export BORG_RSH="${pkgs.openssh}/bin/ssh -i /home/mike/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new"
            
            # Fetch passphrase via the configured command
            export BORG_PASSPHRASE="$(${cfg.passphraseCommand})"
            
            TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

            echo "=== Starting backup for ${clientName} at $TIMESTAMP ==="

            ${pkgs.borgbackup}/bin/borg create \
              --verbose --stats --compression zstd \
              ${clientCfg.repo}::"${clientName}-backup-$TIMESTAMP" \
              ${lib.concatStringsSep " " clientCfg.paths}

            ${pkgs.borgbackup}/bin/borg prune \
              --keep-last 7 --keep-daily 7 --keep-weekly 4 --keep-monthly 6 \
              ${clientCfg.repo}
          '';
        };
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
      };
    }) relevantClients;

    # Timers (Filtered the same way)
    systemd.timers = let 
      relevantClients = lib.filterAttrs (n: _: n == config.networking.hostName) cfg.clients;
    in lib.mapAttrs' (clientName: clientCfg: {
      name = "borg-backup-${clientName}";
      value = {
        description = "Timer for borg-backup-${clientName}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = clientCfg.schedule;
          Persistent = true;
        };
      };
    }) relevantClients;
  };
}
