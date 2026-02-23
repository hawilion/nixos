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
    # Force the use of the CUDA-enabled package
    package = lib.mkForce pkgs.ollama-cuda;
  };

  # This allows your user 'mike' to talk to the Ollama service
  users.users.mike.extraGroups = [ "ollama" ];

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
