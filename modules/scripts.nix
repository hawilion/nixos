{ config, pkgs, lib, ... }:

let
  scriptDir = "$HOME/bin";
in
{
  # Prepend ~/bin to PATH safely
  environment.sessionVariables.PATH = lib.mkBefore "${scriptDir}";

  programs.bash.enable = true;

  programs.bash.shellInit = ''
    unset PROMPT_COMMAND
    if [ "$EUID" -eq 0 ]; then
      PS1="\[\e[31m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\# "
    else
      PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "
    fi
  '';
programs.bash.shellAliases = {
  hxs = "hx /etc/nixos/modules/scripts.nix"; # Add this
  nrf = "sudo nixos-rebuild switch --flake /etc/nixos";
  conf = "hx /etc/nixos";                   # Add this
  hxconf = "hx /etc/nixos/configuration.nix && nix-instantiate --parse /etc/nixos/configuration.nix";
  backup = "sudo /etc/nixos/backup_menu.sh"; # Just the command name
  scan = "scan.sh";
  calc = "libreoffice --calc";
  writer = "libreoffice --writer";
  notes = "glow /etc/nixos/README.md";
  edscripts = "sudo nano /etc/nixos/modules/scripts.nix";
    };

}

