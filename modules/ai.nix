{ config, lib, unstable, ... }:

{
  # Enable Ollama with CUDA support
  services.ollama = {
    enable = true;
    acceleration = "cuda"; # Switched from vulkan to cuda for your 3050
  };

  services.open-webui = {
    enable = true;
    package = unstable.open-webui;
    port = 8080;
    host = "127.0.0.1";
  };

  # Allow Unfree for NVIDIA and Open WebUI
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "open-webui"
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
  ];
}
