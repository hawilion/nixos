{
  hp = {
    repo = "ssh://mike@192.168.79.72/mnt/backupdisk/borg/hp";
    paths = [ "/home/mike" "/etc/nixos" ];
  };

  nixosServer = {
    repo = "/mnt/backupdisk/borg/nixos-server";
    paths = [ "/srv" "/var/lib" "/etc/nixos" ];
  };
}
#backup time defaults to daily no need to set it here
