{ config, pkgs, lib,... }:

{
  # 1. Define the Secrets (Borg + Syyncthing)
  sops.secrets = {
    borg_passphrase = { owner = lib.mkForce "mike"; };
#    syncthing_password = { owner = "mike"; };
  };

  # 2. The Borg Job (Uses the built-in NixOS service)

services.borgbackup.jobs."${config.networking.hostName}" = {
  paths = [ "/home/mike" "/etc/nixos" ];
  exclude = [ "**/.cache" "**/Downloads" ];
  user = "mike";
  
  # Dynamically set the repo path based on the current hostname
  repo = "mike@192.168.79.72:/mnt/backupdisk/borg/${config.networking.hostName}";
  
  # Timer and scheduling settings
  startAt = "daily";
#  timerOptions = {
  persistentTimer = true;  # This ensures the job runs if it missed the scheduled time
# };
  
  encryption = {
    mode = "repokey-blake2";
    # This reads the decrypted secret directly from the sops-nix managed file
    passCommand = "cat /run/secrets/borg_passphrase";
  };

  environment = {
    "BORG_RSH" = "ssh -i /home/mike/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new";
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

  


  # 3. Syncthing Config
 # services.syncthing = {
  #  enable = true;
   # user = "mike";
    #dataDir = "/home/mike";
    #gui = {
     # password = "$(cat /run/secrets/syncthing_password)";
   # };
 # };
}
