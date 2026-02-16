{ config, pkgs, lib, ... }:

let
  secrets = config.sops.secrets;
in
{
  # Networking
  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  services.syncthing = {
  enable = true;
  user = "mike";
  group = "users";
  
  # Keep these as you have them
  dataDir = "/home/mike/.local/state/syncthing";
  configDir = "/home/mike/.config/syncthing";

  # Point these to the "source" files you just found with ls
  cert = "/home/mike/syncthing/cert.pem";
  key  = "/home/mike/syncthing/key.pem";


    overrideDevices = false; 
    overrideFolders = false;

    settings = {
      deviceName = config.networking.hostName;
      
      # Performance and behavior tweaks
      options = {
        databaseTuning = "small";
        maxFolderConcurrency = 1;
        maxConcurrentIncomingRequestKiB = 32768;
        urAccepted = -1; # Opt-out of usage reporting
      };

      gui = {
        address = "0.0.0.0:8384";
        user = "mike";
       # passwordFile = secrets."syncthing-gui-password".path;
      };

      devices = {
        "hp" = { id = "YFFNFOZ-WAWKGY5-BM3P3HM-EEEQTR5-PLYYUVQ-3ZLMNRG-5KJZRJH-4OCZTA6"; };
        "pixel10" = { id = "SFARPSJ-2BWOM56-TEGSLNE-RGZ4Q62-TGBVOSM-FF46EVT-FB32HU7-YOLOWAK"; };
        "lenovo" = { id = "YFFNFOZ-WAWKGY5-BM3P3HM-EEEQTR5-PLYYUVQ-3ZLMNRG-5KJZRJH-4OCZTA6"; }; # Keep commented until you have the ID
      };

      folders = {
        "mlog" = { 
          path = "/home/mike/mlog"; 
          devices = [ "pixel10" ]; 
          id = "ghirq-khoky"; 
        };
        "Camera" = { 
          path = "/home/mike/Camera"; 
          devices = [ "pixel10" ]; 
          id = "5eiix-mjsab"; 
          ignorePerms = false; 
        };
      };
    };
   };
  # Prevents the "Default Folder" from being created on every new device
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
