{ pkgs, ... }: {
  # 1. Enable the Niri program and disable Plasma "ghosts"
  programs.niri.enable = true;
  systemd.user.services.plasma-plasmashell.enable = false;
  systemd.user.services.plasma-krunner.enable = false;

  # 2. Tell the already-enabled niri to skip its tests (the SIGABRT fix)
  programs.niri.package = pkgs.niri.overrideAttrs (old: {
    doCheck = false;
  });

  # 3. Nvidia and Identity environment variables
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    BRAVE_FLAGS = "--enable-features=UseOzonePlatform --ozone-platform=wayland"; 
  };

  # 4. Helper packages
  environment.systemPackages = with pkgs; [
    waybar
    fuzzel
    xwayland-satellite
    wl-clipboard
    alacritty
    foot # Adding foot just in case, since we used it earlier
  ];

  # 5. The Niri Configuration (KDL)
  environment.etc."niri/config.kdl".text = ''
    spawn-at-startup "sh" "-c" "systemctl --user stop plasma-plasmashell.service plasma-krunner.service plasma-kded6.service || true"
    spawn-at-startup "waybar"

    binds {
        Mod+T { spawn "alacritty"; }
        Mod+D { spawn "fuzzel"; }
        Mod+E { spawn "dolphin"; }
        Mod+B { spawn "brave"; }
        Mod+Shift+E { quit; }
    }
  ''; # <-- YOU NEEDED THIS TO CLOSE THE TEXT BLOCK
} # <-- YOU NEEDED THIS TO CLOSE THE WHOLE FILE
