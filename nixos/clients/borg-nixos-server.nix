{
  services.borgBackup.clients.nixos-server = {
    repo = "/mnt/backupdisk/borg/nixos-server";
    backupPaths = [ "/etc/nixos" "/var/lib" "/home" ];
    excludePaths = [ "/var/lib/cache" "/home/*/.cache" ];
 logDir = "/var/log/borg-backup";
};
}
