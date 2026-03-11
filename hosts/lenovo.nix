{ config, lib, pkgs, ... }:

let
  allClients = import ../clients/default.nix;
in
{
  networking.hostName = "lenovo";

  imports = [
    ../hardware-lenovo.nix
    ../modules/ai.nix
    ../modules/borg-backup.nix
  ];

  # ─── KERNEL PARAMS ──────────────────────────────────────────────────────
  boot.kernelParams = [
    "snd_intel_dspcfg.dsp_driver=3"
    "snd_hda_intel.model=dual-codecs"
  ];

  # ─── NVIDIA & GRAPHICS ──────────────────────────────────────────────────
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    open = false;  
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true; 
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
  users.users.mike.extraGroups = [ "ollama" ];

  environment.shellAliases = {
    stop-ai = "sudo systemctl stop ollama && pkill -9 .ollama-wrapped";
    start-ai = "sudo systemctl start ollama";
  };
}
