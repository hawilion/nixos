{ config, lib, pkgs, ... }:

{
  networking.hostName = "lenovo";

  # Enable NVIDIA drivers
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

hardware.nvidia = {
    # 1. Force the proprietary driver (MUCH more stable for Laptop 3050s)
    open = false; 

    # 2. Critical for Raptor Lake power management
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true; # Allows the GPU to sleep when not in use

    # 3. Use the stable production driver
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # These now match your lspci output exactly
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

services.ollama = {
  enable = true;
  acceleration = "cuda";
  # Tweak: Prevent Ollama from hogging all CPU threads
  # Change '4' to half of your total CPU threads if you have a powerful chip
  environmentVariables = {
    OLLAMA_NUM_PARALLEL = "1"; 
    # This ensures it doesn't try to run multiple models at once on the CPU
  };
environmentVariables = {
    # 1. Unload from GPU after 5 minutes of inactivity
      OLLAMA_KEEP_ALIVE = "5m";
      # 2. Limit the number of threads Ollama can spawn
      OMP_NUM_THREADS = "4";
  };
};

  # This allows your user 'mike' to talk to the Ollama service
  users.users.mike.extraGroups = [ "ollama" ];
environment.shellAliases = {
    # The 'Panic Button'
    stop-ai = "sudo systemctl stop ollama && pkill -9 .ollama-wrapped";
    # The 'Resume' button
    start-ai = "sudo systemctl start ollama";
  };

services.open-webui = {
    enable = true;
    port = 8080;
    openFirewall = true; # Allow access from other devices on your LAN
    environment = {
      # This points the UI to your local Ollama instance
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
    };
  };

#Borg Backup Configuration
borgBackup = {
    enable = true;
    clients.lenovo = {
      paths = [ 
        "/home/mike" 
        "/etc/nixos"
        "/var/lib/open-webui"
      ];
      # Added mkForce here to override the value in configuration.nix
      repo = lib.mkForce "mike@192.168.79.72:/home/mike/backups/lenovo-repo";
      schedule = "02:00:00"; 
    };
    # You already have this forced from the previous step
    passphraseCommand = lib.mkForce "${pkgs.coreutils}/bin/cat /etc/borg-passphrase";
  };
}
