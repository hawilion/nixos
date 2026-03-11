{ config, pkgs, lib, ... }:

{
  sops.secrets.borg_passphrase = {
    owner = "mike";
    mode = "0400";
  };

  services.borgbackup.jobs."${config.networking.hostName}" = {
    paths = [ "/home/mike" "/etc/nixos" ];
    exclude = [ "**/.cache" "**/Downloads" ];
    user = "mike";
    
    repo = "mike@192.168.79.72:/mnt/backupdisk/borg/${config.networking.hostName}";
    
    # 2:00 PM daily, with persistence so it catches up if you were asleep
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

  # Dependency and Retry logic
  systemd.services."borgbackup-job-lenovo" = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
      StartLimitBurst = 3;
      StartLimitIntervalSec = 900;
    };
  };
}
