{
  description = "Lenovo client NixOS configuration with SOPS and Borg backup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.lenovo = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      modules = [
        ./configuration.nix
        ./hosts/lenovo.nix
        ./modules/cad.nix
        ./modules/borg-backup.nix
        ./modules/scripts.nix
        sops-nix.nixosModules.sops
      ];
    };
  };
}
