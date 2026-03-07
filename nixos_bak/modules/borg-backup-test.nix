{ config, pkgs, lib, ... }:

let
  clients = import /etc/nixos/clients/default.nix;
in
trace "Clients detected: ${lib.concatStringsSep ", " (lib.attrNames clients)}" {}
