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
  systemd.services."borgbackup-job-${config.networking.hostName}" = {
    # These belong at the top level of the service definition, NOT in serviceConfig
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      # Running as root ensures permission to read /etc/nixos/secrets
      # If your backup script uses specific paths, ensure they are absolute
      #User = "root";
    };
  };
}
