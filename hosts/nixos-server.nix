{ config, pkgs, lib,  ... }:

{
  imports = [
    ./hardware-configuration.nix  # The file we just made
    ../modules/nextcloud-server.nix  # The "Brain" for your phone sync
    ../modules/borg-backup.nix       # The "Vault" for your tax receipts
    ../modules/scripts.nix           # Your "nrf" and "hx" aliases
  ];

  # Bootloader (Standard for most servers)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixos-server";
    interfaces.enp0s25.ipv4.addresses = [
      { address = "192.168.79.80"; prefixLength = 24; }
    ];
    defaultGateway = "192.168.79.1";
    nameservers = [ "1.1.1.1" ];
  };  
  sops.secrets."borg_passphrase" = {
    owner = "mike";
  };

  # This is the "Open Door" for your Lenovo
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Set your time zone for the farm records
  time.timeZone = "Pacific/Honolulu";

  # Define your user account so you can still log in!
  users.users.mike = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  services.syncthing.enable = lib.mkForce false;

  system.stateVersion = "25.05"; 
}
