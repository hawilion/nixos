{ config, pkgs, lib, ... }:

let
  secrets = config.sops.secrets;
in
{
  # Firewall for Syncthing
  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ]; 

  # Syncthing service
  services.syncthing = {
    enable = true;
    user = "mike";
    group = "users";
    openDefaultPorts = true;
    dataDir = "/home/mike/.local/state/syncthing";
    configDir = "/home/mike/.config/syncthing";

    overrideDevices = false;  # don’t overwrite WebUI devices
    overrideFolders = false;  # don’t overwrite WebUI folders

    settings = {
      databaseTuning = "small";
      maxFolderConcurrency = 1;
      maxConcurrentIncomingRequestKiB = 32768;

      gui = {
        address = "127.0.0.1:8384";
        enabled = true;
        theme = "dark";
        user = "mike";
#       passwordFile = secrets."syncthing-gui-password".path;  # pulled from SOPS
      };

      devices = {
        "nixos" = { id = "YFFNFOZ-WAWKGY5-BM3P3HM-EEEQTR5-PLYYUVQ-3ZLMNRG-5KJZRJH-4OCZTA6"; };
        "pixel6" = { id = "SFARPSJ-2BWOM56-TEGSLNE-RGZ4Q62-TGBVOSM-FF46EVT-FB32HU7-YOLOWAK"; };
      };

      folders = {
        "mlog" = { path = "/home/mike/mlog"; devices = [ "pixel6" ]; id = "ghirq-khoky"; };
        "Camera" = { path = "/home/mike/Camera"; devices = [ "pixel6" ]; id = "5eiix-mjsab"; ignorePerms = false; };
      };

      # TLS files from SOPS
      tls = {
      certFile = "/home/mike/.config/syncthing/cert.pem";
      keyFile  = "/home/mike/.config/syncthing/key.pem";
      };
    };
  };

  # Systemd environment tweaks
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
