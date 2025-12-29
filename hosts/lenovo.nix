{ config, lib, pkgs, ... }:

{
  networking.hostName = "lenovo";

  # This must be INSIDE the main curly braces
  borgBackup = {
    enable = true;
    # lib.mkForce overrides the old /root/bin/ script in configuration.nix
    passphraseCommand = lib.mkForce "${pkgs.coreutils}/bin/cat /etc/borg-passphrase";
  };
}
