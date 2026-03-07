{ config, pkgs, lib, ... }:

let
  cfg = config.backup;
in
{
  options.backup = {
    enable = lib.mkEnableOption "Enable Borg backup system";
    clients = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrs);
      default = {};
      description = "Per-client Borg backup definitions.";
    };
    extraBorgArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra arguments to pass to Borg.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs' (clientName: client:
      let
        # Borg command and environment setup
        borgCmd = ''
          export BORG_REPO="${client.repo}"
          export BORG_PASSPHRASE="$(sops -d --extract '["borg-passphrase"]' /etc/nixos/secrets/secrets.yaml 2>/dev/null)"
          borg create ${lib.concatStringsSep " " cfg.extraBorgArgs} \
            --verbose --filter AME --list --stats --show-rc \
            --compression lz4 \
            "::${client.name}-{now:%Y-%m-%d_%H:%M:%S}" \
            ${lib.concatStringsSep " " client.paths} \
            ${lib.optionalString (client ? excludeFile) "--exclude-from ${client.excludeFile}"}

          backup_exit=$?
          echo "🏁 Borg exited with code: $backup_exit"

          echo "Pruning old archives..."
          borg prune --list --prefix "${client.name}-" --keep-daily=7 --keep-weekly=4 --keep-monthly=6
        '';
      in
      {
        name = "borgbackup-${clientName}";
        value = {
          description = "Borg backup for ${clientName}";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = [ "${pkgs.bash}/bin/bash -c '${borgCmd}'" ];
            User = "root";
            StandardOutput = "append:/var/log/borgbackup-${clientName}.log";
            StandardError = "append:/var/log/borgbackup-${clientName}.log";
          };
        };
      }
    ) cfg.clients;

    # Timers per client
    systemd.timers = lib.mapAttrs' (clientName: client: {
      name = "borgbackup-${clientName}";
      value = {
        description = "Run Borg backup for ${clientName} on schedule";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = client.schedule;
          Persistent = true;
        };
      };
    }) cfg.clients;

    # Create log directory
    systemd.tmpfiles.rules = [
      "d /var/log/borg-backup 0750 root root -"
    ];
  };
}
