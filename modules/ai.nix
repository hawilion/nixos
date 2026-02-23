{ config, lib, pkgs, unstable, ... }:

{
  # 1. Enable Ollama with specific RTX 3050 optimizations
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    # Use the stable or unstable package as preferred; usually stable is fine for Ollama
    package = pkgs.ollama-cuda; 

    environmentVariables = {
      # Tweak: Auto-unload model from 3050 VRAM after 5 mins of inactivity
      OLLAMA_KEEP_ALIVE = "5m";
      # Tweak: Prevent CPU from hitting 100% by limiting calculation threads
      # Set this to roughly half of your physical CPU cores
      OMP_NUM_THREADS = "4";
      # Ensure it only tries to run one model at a time to save VRAM
      OLLAMA_NUM_PARALLEL = "1";
    };
  };

  # 2. Open WebUI (The "Gemini" Interface)
  services.open-webui = {
    enable = true;
    package = unstable.open-webui;
    port = 8080;
    host = "127.0.0.1";
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
    };
  };

  # 3. Handle Unfree licenses for NVIDIA and AI tools
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "ollama"
    "open-webui"
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
    "cuda_cudart"
    "cuda_nvcc"
    "libcublas" # This is what took 99% CPU to build earlier!
    "cuda_cccl"
  ];

  # 4. Open the firewall for WebUI if you want to use it from your phone/tablet
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
