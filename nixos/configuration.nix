{ config, pkgs, lib, ... }:

let
  clients = import ./clients/default.nix { inherit pkgs lib; };
in
{
  #### ─── Imports ────────────────────────────────────────────────
  imports = [
    ./hardware-configuration.nix
    ./modules/borg-backup.nix
  ];

  #### ─── Networking ─────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.interfaces.enp0s25.ipv4.addresses = [
    { address = "192.168.79.80"; prefixLength = 24; }
  ];
  networking.defaultGateway = "192.168.79.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.firewall.allowedTCPPorts = [ 22 443 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  #### ─── Time & Locale ─────────────────────────────────────────
  time.timeZone = "Pacific/Honolulu";
  i18n.defaultLocale = "en_US.UTF-8";

  #### ─── Users ─────────────────────────────────────────────────
  users.users.mike = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ kdePackages.kate kdePackages.kde-cli-tools ];
  };

  users.users.root.shell = pkgs.bashInteractive;

  #### ─── Environment & Shell Aliases ───────────────────────────
  environment.systemPackages = with pkgs; [
    borgbackup sops jq openssh tree ripgrep bash coreutils findutils gzip curl wget
    gparted openssl parted util-linux age go syncthing anki-bin xsane gscan2pdf
    nmap plocate neovim logseq certbot nextcloud-client libnotify timeshift yq 

    
  ];

  environment.shellAliases = {
    nrf = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";

    backuplog = "sudo journalctl -u borgbackup-hp.service -e --no-pager -n 50";
    restorelog = "sudo journalctl -u restore-etc-nixos-hp.service -e --no-pager -n 50";

    backetc = ''
      bash -c '
        echo "[backetc] 🔄 Starting backup at $(date)" | systemd-cat -t backetc
        sudo bash /etc/nixos/backup-etc-nixos-hp.sh
        status=$?
        if [ $status -eq 0 ]; then
          echo "[backetc] ✅ Backup completed successfully at $(date)" | systemd-cat -t backetc
        else
          echo "[backetc] ❌ Backup failed at $(date) with code $status" | systemd-cat -t backetc
        fi
        exit $status
      '
    '';

    restoreetc = "sudo bash /etc/nixos/restore-etc-nixos-hp.sh";
    borglog    = "sudo journalctl -u borgbackup-hp.service -r";
  };

  #### ─── Programs ──────────────────────────────────────────────
  programs.firefox.enable = true;
  programs.ssh.startAgent = true;

  #### ─── SSH Config ────────────────────────────────────────────
  environment.etc."ssh/ssh_config".text = ''
    Host nixos-server
      HostName 192.168.79.72
      User mike
      IdentityFile ~/.ssh/id_ed25519
      IdentitiesOnly yes
  '';

  environment.etc."ssh/known_hosts".text = ''
    nixos-server ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINURdP5aQJxYI3h/KGPm9QjlPmJHcOr5ZClJobfuWpi mlillie57@gmail.com
  '';

  #### ─── Desktop & Multimedia ──────────────────────────────────
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;
  services.printing.enable = true;

  #### ─── OpenSSH server ────────────────────────────────────────
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
    PubkeyAuthentication = true;
    AllowUsers = [ "mike" ];
    X11Forwarding = false;
  };

  #### ─── Borg Backup ───────────────────────────────────────────
  backup = {
    enable = true;
    clients = import ./clients/default.nix { inherit pkgs lib; };
#    extraBorgArgs = [ "--filter" "AME" ];
  };

  #### ─── Systemd tmpfiles ─────────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /var/log/borg-backup 0750 root root -"
  ];

  #### ─── Logrotate for Borg backups ───────────────────────────
  services.logrotate = {
    enable = true;

    # Automatically create logrotate settings per client
    settings = lib.genAttrs (lib.attrNames clients) (clientName:
      let client = clients.${clientName}; in
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

  #### ─── Bootloader ───────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #### ─── Nix settings ─────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 67108864;

# =========================
# Automatic Nix Garbage Collection (NixOS)
# =========================
nix.gc = {
  automatic = true;               # enable automatic GC
  dates = "weekly";               # run weekly
  options = "--delete-older-than 30d";  # delete old generations older than 30 days
};


  #### ─── State version ────────────────────────────────────────
  system.stateVersion = "25.05";
}
