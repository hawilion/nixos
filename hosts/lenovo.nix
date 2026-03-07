{ config, lib, pkgs, ... }:

let
  # Import your client database here so it's available to the rest of the file
  allClients = import ../clients/default.nix;
in
{
  networking.hostName = "lenovo";

  imports = [
    ../hardware-lenovo.nix
    ../modules/ai.nix
    ../modules/borg-backup.nix
  ];
  # ─── NVIDIA & GRAPHICS ──────────────────────────────────────────────────
  # This stays here because it's specific to the Lenovo's physical hardware
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    open = false; 
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true; # Critical for battery life

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ─── AI MODULE DATA ─────────────────────────────────────────────────────
  # Note: The 'services.ollama' and 'services.open-webui' blocks are 
  # now inside modules/ai.nix. We only put Lenovo-specific tweaks here.
  
  users.users.mike.extraGroups = [ "ollama" ];

  environment.shellAliases = {
    stop-ai = "sudo systemctl stop ollama && pkill -9 .ollama-wrapped";
    start-ai = "sudo systemctl start ollama";
  };

  # ─── BORG BACKUP DATA ───────────────────────────────────────────────────
  # We use the 'options' we created in modules/borg-backup.nix
 # borgBackup = {
  #  enable = true;
    # Pull the specific 'lenovo' data from your clients/default.nix
   # clients = {
    #  lenovo = allClients.lenovo // {
        # We add the WebUI database to the paths here
     #   paths = allClients.lenovo.paths;
      #};
    #};
  #};
}
