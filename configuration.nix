{ config, pkgs, lib, ... }:

let
  backupClients = import ./clients/default.nix;
in
{
  # ------------------------------------------------
  # GLOBAL NIXPKGS SETTINGS
  # ------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  # ------------------------------------------------
  # MODULE IMPORTS
  # ------------------------------------------------
  imports = [
    ./hardware-configuration.nix
    ./modules/borg-backup.nix
    ./modules/printers.nix
  ];

  # ------------------------------------------------
  # BORG BACKUP
  # ------------------------------------------------
  borgBackup = {
    enable = true;
    clients = backupClients;
    passphraseCommand = "/root/bin/get-borg-pass.sh";
  };

  # ------------------------------------------------
  # NETWORKING
  # ------------------------------------------------
  networking = {
    networkmanager.enable = true;

    interfaces.enp0s25.ipv4.addresses = [
      { address = "192.168.79.80"; prefixLength = 24; }
    ];

    defaultGateway = "192.168.79.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    firewall.allowedTCPPorts = [ 22 443 8384 22000 ];
    firewall.allowedUDPPorts = [ 22000 21027 ];
  };

  # ------------------------------------------------
  # LOCALE
  # ------------------------------------------------
  time.timeZone = "Pacific/Honolulu";
  i18n.defaultLocale = "en_US.UTF-8";

  # ------------------------------------------------
  # USERS
  # ------------------------------------------------
  users.users.mike = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kde-cli-tools
    ];
  };

  users.users.root.shell = pkgs.bashInteractive;

  # ------------------------------------------------
  # SYSTEM PACKAGES
  # ------------------------------------------------
  environment.systemPackages = with pkgs; [
    borgbackup sops jq openssh tree ripgrep bash coreutils findutils
    curl wget parted util-linux age go syncthing xsane nmap
    plocate neovim logseq nextcloud-client libnotify yq imagemagick
    img2pdf zenity sane-backends sane-airscan sane-frontends brscan4
    vim imagemagick brave kdePackages.kconfig qt6.qttools git

  ];
 
  # ------------------------------------------------
  # PROGRAMS
  # ------------------------------------------------
  programs = {
    firefox.enable = true;
    ssh.startAgent = true;
    git.enable = true; 
  };
#   programs.bash = {
 # enable = true;
  #promptInit = ''
   #  if [ "$EUID" -eq 0 ]; then
    #    PS1="\[\e[31m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\# "
   # else
    #    PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "
   # fi
  #'';
#};

  # ------------------------------------------------
  # HARDWARE / SCANNER
  # ------------------------------------------------
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.brscan4 ];
  };

  # ------------------------------------------------
  # SERVICES
  # ------------------------------------------------
  services = {
    xserver.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    pipewire.enable = true;
    pipewire.alsa.enable = true;
    pipewire.pulse.enable = true;

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
        PubkeyAuthentication = true;
        AllowUsers = [ "mike" ];
      };
    };

    logrotate.enable = true;

    logrotate.settings = lib.genAttrs (lib.attrNames backupClients) (clientName:
      let client = backupClients.${clientName}; in
      {
        path = "/var/log/borgbackup-${clientName}.log";
        rotate = 7;
        daily = true;
        compress = true;
        missingok = true;
        notifempty = true;
        copytruncate = true;
      }
    );
  };

  # ------------------------------------------------
  
  # TMPFILES CLEANUP
  # ------------------------------------------------
  systemd.tmpfiles.rules = [
    "r /etc/systemd/system/nixosServer.timer"
    "r /etc/systemd/system/nixosServer.service"
  ];

  # ------------------------------------------------
  # BROTHER NETWORK SCANNER SYSTEMD SERVICE
  # ------------------------------------------------
  systemd.user.services.brother-scan = {
    description = "Register Brother network scanner";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        mkdir -p $HOME/.brscan4
        export BRSANE_CFG_DIR=$HOME/.brscan4
        ${pkgs.brscan4}/bin/brsaneconfig4 -a name=MFC-L2710DW model=MFC-L2710DW ip=192.168.79.190 || true
      '';
    };
    enable = true;
  };

  # ------------------------------------------------
  # BOOTLOADER
  # ------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ------------------------------------------------
  # NIX SETTINGS
  # ------------------------------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 67108864;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.etc."profile.d/custom-path.sh".text = ''
  export PATH=$HOME/bin:$PATH
'';

  # ------------------------------------------------
  # NEOVIM CONFIG
  # ------------------------------------------------
  environment.etc."nvim-config/init.lua".source = ./nvim-config/init.lua;

  system.activationScripts.nvim-symlink.text = ''
    mkdir -p /home/mike/.config/nvim
    ln -sf /etc/nixos/nvim-config/init.lua /home/mike/.config/nvim/init.lua
    chown -R mike:users /home/mike/.config/nvim
  '';


  # ------------------------------------------------
  # STATE VERSION
  # ------------------------------------------------
  system.stateVersion = "25.05";
}
