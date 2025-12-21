{
  description = "HP client NixOS configuration with SOPS and Borg backup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
        ./modules/borg-backup.nix
        sops-nix.nixosModules.sops
      ];
    };
  };
}

