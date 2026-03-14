{ config, pkgs, ... }:

{
  sops.secrets.borg_passphrase = {
    owner = "mike";
    mode = "0400";
  };

  # 1. Define the Backup Job
  services.borgbackup.jobs."${config.networking.hostName}" = {
    paths = [ "/home/mike" "/etc/nixos" ];
    exclude = [ "**/.cache" "**/Downloads" ];
    user = "mike";
    
    repo = "mike@192.168.79.72:/mnt/backupdisk/borg/${config.networking.hostName}";
    
    startAt = "14:00:00";
    persistentTimer = true;
    
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /run/secrets/borg_passphrase";
    };

    environment = {
      "BORG_RSH" = "ssh -i /home/mike/.ssh/id_ed25519 -o BatchMode=yes -o ConnectTimeout=10";
    };

    compression = "auto,zstd";
    
    prune = {
      keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
  };

  # 2. Define the Systemd settings for the service that Borg created
  systemd.services."borgbackup-job-${config.networking.hostName}" = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
      StartLimitBurst = 3;
      StartLimitIntervalSec = 900;
      # This helps if the service needs access to SSH keys
      ReadWritePaths = [ "/home/mike/.ssh" ];
    };
  };
}
