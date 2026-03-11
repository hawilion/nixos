{ config, pkgs, lib, ... }:

{
  # 1. Define the Secret
  sops.secrets.borg_passphrase = {
    owner = "mike";
    mode = "0400";
  };

  # 2. Define the Borg Job
  services.borgbackup.jobs."${config.networking.hostName}" = {
    paths = [ "/home/mike" "/etc/nixos" ];
    exclude = [ "**/.cache" "**/Downloads" ];
    user = "mike";
    
    repo = "mike@192.168.79.72:/mnt/backupdisk/borg/${config.networking.hostName}";
    
    startAt = "daily";
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

  # 3. Correctly define systemd dependencies


systemd.services."borgbackup-job-lenovo" = {
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  serviceConfig = {
    Restart = "on-failure";
    RestartSec = "5min"; # Wait 5 minutes before trying again
    StartLimitBurst = 3; # Try 3 times total
    StartLimitIntervalSec = 900; # Over a 15-minute window
  };
};


}
