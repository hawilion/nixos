{ pkgs, lib, ... }:

{
  enable = true;

  # Backup repository lives on NixOS server
  repo = "mike@192.168.79.72:/mnt/backupdisk/borg/lenovo";

  # Paths on the Lenovo machine (remote via SSH)
  backupPaths = [
    "ssh://mike@192.168.79.93//home/mike/Documents"
    "ssh://mike@192.168.79.93//home/mike/Desktop"
    "ssh://mike@192.168.79.93//home/mike/Pictures"
  ];

  excludePaths = [
    "ssh://mike@192.168.79.93//home/mike/.cache"
    "ssh://mike@192.168.79.93//home/mike/Downloads"
  ];

  logDir = "/var/log/borg-backup";
}

