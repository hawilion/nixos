{ config, pkgs, ... }:

{
  imports = [ ../hardware-hp.nix ]; # This links to your HP hardware config
  networking.hostName = "hp"; 
}
