{ config, lib, pkgs, ... }:

{
  networking.hostName = "hp";

  imports = [
    ../hardware-hp.nix
    # Do NOT import ../modules/ai.nix if the HP lacks the GPU power for it
  ];

  # HP-specific settings (add these if needed)
  # hardware.enableRedistributableFirmware = true; 
  
  # Ensure you don't have any NVIDIA settings here!
}
