{ config, pkgs, lib, ... }:

let
  backupClients = import ./clients/default.nix;
in
{
  # ------------------------------------------------
  # GLOBAL NIXPKGS & SYSTEM SETTINGS
  # ------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 67108864;
  
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ------------------------------------------------
  # MODULE IMPORTS
  # ------------------------------------------------
  imports = [
    #./hardware-configuration.nix
    ./modules/borg-backup.nix
    ./modules/printers.nix
    ./modules/syncthing.nix
    ./modules/libreoffice-minimal.nix
  ];

  # ------------------------------------------------
  # BOOTLOADER & KERNEL (Audio Fixes)
  # ------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ------------------------------------------------
  # HARDWARE / FIRMWARE / SCANNER
  # ------------------------------------------------
  hardware.enableAllFirmware = true;
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.brscan4 ];
  };

  # ------------------------------------------------
  # NETWORKING
  # ------------------------------------------------
  networking = {
    networkmanager.enable = true;
    #hostName = "lenovo";
    interfaces.enp0s25.ipv4.addresses = [
      { address = "192.168.79.80"; prefixLength = 24; }
    ];
    defaultGateway = "192.168.79.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall.allowedTCPPorts = [ 22 443 8384 22000 ];
    firewall.allowedUDPPorts = [ 22000 21027 ];
  };

  # ------------------------------------------------
  # SERVICES (Audio, Desktop, and Others)
  # ------------------------------------------------
  security.rtkit.enable = true; # Required for PipeWire real-time priority

  services = {
    xserver.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    flatpak.enable = true;
    libreoffice-minimal.enable = true;

    # PIPEWIRE AUDIO CONFIGURATION
    pulseaudio.enable = false; # Disable old PulseAudio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;      # Allows YouTube/Browsers to play sound
      wireplumber.enable = true;
    };

    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = true;
        disableWhileTyping = true;
        clickMethod = "clickfinger";
      };
      mouse = {
        accelProfile = "flat";
        accelSpeed = "0.0";
      };
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        AllowUsers = [ "mike" ];
      };
    };

    logrotate = {
      enable = true;
      settings = lib.genAttrs (lib.attrNames backupClients) (clientName: {
        path = "/var/log/borgbackup-${clientName}.log";
        rotate = 7;
        daily = true;
        compress = true;
        copytruncate = true;
      });
    };
  };

  # ------------------------------------------------
  # BORG BACKUP
  # ------------------------------------------------
  #borgBackup = {
   # enable = true; # Uncomment this to turn it on!
    #clients = backupClients;
    # IMPORTANT: Use /run/secrets/ instead of /etc/secrets/
    #passphraseCommand = "cat /run/secrets/borg_passphrase";
 # };

  # ------------------------------------------------
  # USERS
  # ------------------------------------------------
  users.users.mike = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" "audio" "video" "open-webui" ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kde-cli-tools
    ];
  };

  # ------------------------------------------------
  # SYSTEM PACKAGES
  # ------------------------------------------------
  environment.systemPackages = with pkgs; [
    borgbackup sops jq openssh tree ripgrep bash coreutils 
    curl wget parted util-linux age syncthing xsane nmap
    plocate neovim logseq nextcloud-client libnotify yq 
    imagemagick img2pdf zenity vim brave git pavucontrol 
    sof-firmware alsa-utils
  ];
  environment.sessionVariables = {
  SOPS_AGE_KEY_FILE = "/home/mike/.config/sops/age/keys.txt";
};

sops = {
  defaultSopsFile = ./secrets/secrets.yaml;
  age.keyFile = "/home/mike/.config/sops/age/keys.txt";

  secrets."borg_passphrase" = {  
    owner = "mike";
  };
  secrets."syncthing-gui-password" = {};
};   

  # ------------------------------------------------
  # SYSTEMD SERVICES & TMPFILES
  # ------------------------------------------------
  systemd.tmpfiles.rules = [
    "r /etc/systemd/system/nixosServer.timer"
    "r /etc/systemd/system/nixosServer.service"
  ];

  systemd.user.services.brother-scan = {
    description = "Register Brother network scanner";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.brscan4}/bin/brsaneconfig4 -a name=MFC-L2710DW model=MFC-L2710DW ip=192.168.79.190";
    };
    wantedBy = [ "default.target" ];
  };

  # ------------------------------------------------
  # MISC CONFIGS
  # ------------------------------------------------
  time.timeZone = "Pacific/Honolulu";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.etc."profile.d/custom-path.sh".text = "export PATH=$HOME/bin:$PATH";
  environment.etc."nvim-config/init.lua".source = ./nvim-config/init.lua;

  system.activationScripts.nvim-symlink.text = ''
    mkdir -p /home/mike/.config/nvim
    ln -sf /etc/nixos/nvim-config/init.lua /home/mike/.config/nvim/init.lua
  '';

  system.stateVersion = "25.05"; 
}
