{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix  # The file we just made
  ];

  # Bootloader (Standard for most servers)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-server";

  # This is the "Open Door" for your Lenovo
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Set your time zone for the farm records
  time.timeZone = "Pacific/Honolulu";

  # Define your user account so you can still log in!
  users.users.mike = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system.stateVersion = "25.05"; 
}
