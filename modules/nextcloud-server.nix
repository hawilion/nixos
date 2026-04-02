{ config, pkgs, lib, ... }: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "nixos-server"; # Update this to your actual domain/IP if needed
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
      adminuser = "admin";
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

  sops.secrets.nextcloud_admin_password = {
    owner = "nextcloud";
  };
}
