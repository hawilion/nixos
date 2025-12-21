{ pkgs, lib }:

{
  hp = {
    name = "hp";
    repo = "ssh://mike@nixos-server//mnt/backupdisk/borg/hp";
    paths = [ "/etc/nixos" "/home/mike" ];
    excludeFile = "/etc/nixos/backup-excludes.txt";
    schedule = "*-*-* 14:00:00";
  };

  nixos-server = {
    name = "nixos-server";
    repo = "ssh://mike@nixos-server//mnt/backupdisk/borg/nixos-server";
    paths = [ "/etc/nixos" "/home" "/var/lib" ];
    excludeFile = "/etc/nixos/backup-excludes.txt";
    schedule = "*-*-* 15:30:00";
  };
}
