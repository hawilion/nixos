{ config, pkgs, lib, ... }: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "lenovo"; 
    database.createLocally = true;
    # REMOVED: webserver.nginx.enable (and all variations)

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbname = "nextcloud";
      adminpassFile = config.sops.secrets.nextcloud_admin_pass.path;
      adminuser = "admin";
    };
  };

  # Use the standard Nginx module to catch the Nextcloud traffic
  services.nginx = {
    enable = true;
    virtualHosts."lenovo" = {
      forceSSL = false; # Set to true once you have certs
      addSSL = false;
      # This line is the "magic" that connects them manually
      locations."/".proxyPass = "http://127.0.0.1:8080"; 
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensureDBOwnership = true;
    }];
  };

  sops.secrets.nextcloud_admin_pass.owner = "nextcloud";
}
