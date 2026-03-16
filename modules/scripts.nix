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
  nrf = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
  backup = "sudo backup_menu.sh"; # Just the command name
  scan = "scan.sh";
  calc = "libreoffice --calc";
  writer = "libreoffice --writer";
    };

}

