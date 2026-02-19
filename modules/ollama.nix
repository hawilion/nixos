{ config, lib, pkgs, ... }:

with lib;

{
  options.services.ollama = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Ollama with CUDA support";
    };
  };

  config = mkIf config.services.ollama.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama.override { acceleration = "cuda"; };
    };

    nixpkgs.config.allowUnfree = true;

    hardware.nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaSettings = true;
    };
  };
}   
