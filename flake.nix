{
  description = "Lenovo NixOS configuration with FreeCAD forced to unstable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable { 
        inherit system; 
        config.allowUnfree = true; 
      };
    in
    {
      nixosConfigurations.lenovo = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit unstable inputs; };  

        modules = [
          ./configuration.nix
          ./hosts/lenovo.nix
          ./modules/cad.nix
          ./modules/borg-backup.nix
          ./modules/scripts.nix
          sops-nix.nixosModules.sops # Correctly referencing the input
        ];
      };
    };
}
