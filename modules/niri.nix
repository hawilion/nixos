{ pkgs, ... }: {
  # 1. Enable the Niri program
  programs.niri.enable = true;

  # 2. Tell the already-enabled niri to skip its tests
  programs.niri.package = pkgs.niri.overrideAttrs (old: {
    doCheck = false;
  });

  # ... (keep your environment.sessionVariables and environment.etc as they were)
  # Hardware/Driver specific environment variables for Niri
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    BRAVE_FLAGS = "--enable-features=UseOzonePlatform --ozone-platform=wayland"; 
  };

  # Helper packages for the Niri environment
  environment.systemPackages = with pkgs; [
    waybar             # Status bar
    fuzzel             # App launcher
    xwayland-satellite # For X11 app support
    wl-clipboard       # Required for copy/paste (Ctrl+Shift+C/V)
    alacritty          # Fast terminal
  ];
# This tells Nix: "Take this text and put it in a file at /etc/niri/config.kdl"
  environment.etc."niri/config.kdl".text = ''
    // Niri Starter Config - March 2026
spawn-at-startup "killall" "plasmashell" "krunner" "kded6"
spawn-at-startup "waybar"
input {
    keyboard {
        xkb {
            layout "us"
        }
    }
    touchpad {
        tap
        natural-scroll
    }
    mouse {
        // Essential for Nvidia cursors if they feel floaty
        accel-speed 0.2
    }
}

layout {
    // This creates the "spacing" between your windows
    gaps 12
    center-focused-column-window
    
    // Default width for new windows (adjust to your monitor size)
    default-column-width { proportion 0.5; }
}

// Keybindings - The "Mod" key is usually the Windows/Super key
binds {
    // --- System Actions ---
    Mod+Shift+E { quit; }
    Mod+Shift+Slash { show-hotkey-overlay; } // Show this list in-app!

    // --- App Launchers ---
    Mod+T { spawn "foot"; }              // Launch your terminal
    Mod+D { spawn "fuzzel"; }            // Launch your app menu
    Mod+B { spawn "firefox"; }           // Launch your browser

    // --- Window Navigation (The "Scroll") ---
    Mod+Left  { focus-column-left; }
    Mod+Right { focus-column-right; }
    Mod+H     { focus-column-left; }     // Vim-style keys
    Mod+L     { focus-column-right; }

    // --- Moving Windows ---
    Mod+Shift+Left  { move-column-left; }
    Mod+Shift+Right { move-column-right; }

    // --- Window Sizing ---
    Mod+R { switch-preset-column-width; } // Cycles through 1/3, 1/2, 2/3 width
    Mod+F { maximize-column; }            // Toggle Fullscreen
    
    // --- Closing Windows ---
    Mod+Q { close-window; }

    // --- Other Binds ---
    Mod+B  { Spawn "brave"; }
}

// Nvidia specific: Ensures smooth rendering
spawn-at-startup "xwayland-satellite"
'';
}

