{
  description = "Lenovo client NixOS configuration with pinned FreeCAD and SOPS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/c6245e83d836d0433170a16eb185cefe0572f8b8"; # pinned commit
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, ... }:
  let
    system = "x86_64-linux";

    # Overlay to pin FreeCAD from unstable
    unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    overlays = [
      (final: prev: {
        freecad = unstable.freecad;
      })
    ];
    pkgs = import nixpkgs { inherit system overlays; };
  in {
    nixosConfigurations.lenovo = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { unstable = unstable; };

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
