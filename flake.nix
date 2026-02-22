{
  description = "Lenovo NixOS configuration with FreeCAD forced to unstable";

  inputs = {
    #main stable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    #ustable branch for latest tools
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, nix-flatpak, ... }@inputs:
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
          ./modules/ai.nix
          sops-nix.nixosModules.sops # Correctly referencing the input
          nix-flatpak.nixosModules.nix-flatpak

       ];
      };
    };
}
