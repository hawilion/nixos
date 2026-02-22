{ config, lib, unstable, ... }:

{
  # 1. Enable Ollama (The Brain)
  services.ollama = {
    enable = true;
    package = unstable.ollama;
    # Recommended for Lenovo (Intel/AMD integrated graphics)
    acceleration = "vulkan"; 
  };

  # 2. Enable Open WebUI (The "Private Gemini" Interface)
  services.open-webui = {
    enable = true;
    package = unstable.open-webui;
    port = 8080;
    host = "127.0.0.1"; # Keeps it strictly on your Lenovo
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
  };

  # 3. Security/License (Open WebUI Branding License)
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "open-webui"
  ];
}
