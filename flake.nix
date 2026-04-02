{
  description = "NixOS configuration for Lenovo and HP";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    niri.url = "github:sodiboo/niri-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, nix-flatpak, niri, ... }@inputs:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable {  
        inherit system;  
        config.allowUnfree = true;  
      };
    in
    {  
      nixosConfigurations = {
        lenovo = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit unstable inputs; };  
          modules = [
            ./configuration.nix
            ./hosts/lenovo.nix
            ./modules/cad.nix
            ./modules/borg-backup.nix
            ./modules/scripts.nix
            ./modules/ai.nix
            ./modules/nextcloud-server.nix
            sops-nix.nixosModules.sops
            nix-flatpak.nixosModules.nix-flatpak
            niri.nixosModules.niri
          ];
        };

        hp = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit unstable inputs; };  
          modules = [
            ./configuration.nix
            ./hosts/hp.nix # Make sure to create this file
            ./modules/borg-backup.nix
            sops-nix.nixosModules.sops
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };
       nixos-server = nixpkgs.lib.nixosSystem {
         inherit system;
         specialArgs = { inherit unstable inputs; };   
         modules = [
           ./configuration.nix
           ./hosts/nixos-server.nix  # Make sure this file exists!
           ./modules/nextcloud-server.nix
           ./modules/borg-backup.nix
           sops-nix.nixosModules.sops
         ];
       };
    };
  };
}
