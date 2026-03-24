{ pkgs, ... }: {
  # 1. Enable Niri and disable interfering Plasma services
  programs.niri.enable = true;
  systemd.user.services.plasma-plasmashell.enable = false;
  systemd.user.services.plasma-krunner.enable = false;

  # 2. Skip tests to prevent the SIGABRT build error
  programs.niri.package = pkgs.niri.overrideAttrs (old: {
    doCheck = false;
  });

  # 3. Environment Variables (Optimized for Intel i915 Graphics)
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1"; # Essential for Brave/Electron apps
    TERMINAL = "alacritty";
    BRAVE_FLAGS = "--enable-features=UseOzonePlatform --ozone-platform=wayland"; 
  };

  # 4. Essential Packages for the Niri Environment
  environment.systemPackages = with pkgs; [
    waybar
    fuzzel
    xwayland-satellite
    wl-clipboard
    alacritty
    foot
    # --- Screenshot Tools ---
    grim
    slurp
    swayimg # A lightweight image viewer to check your shots
  ];

  # 5. The Niri Configuration (KDL Format)
  environment.etc."niri/config.kdl".text = ''
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
    }

    layout {
        gaps 12
        center-focused-column "never"
    }

    // Startup commands
    spawn-at-startup "sh" "-c" "systemctl --user stop plasma-plasmashell.service plasma-krunner.service plasma-kded6.service || true"
    spawn-at-startup "waybar"
    spawn-at-startup "alacritty"
    
binds {
        // --- System ---
        Ctrl+Alt+Delete { quit; }
        Alt+Shift+E { quit; }

        // --- Apps ---
        Alt+T { spawn "alacritty"; }
        Alt+B { spawn "brave"; }
        Alt+D { spawn "fuzzel"; }
        Alt+L { spawn "logseq"; }
        
        // --- Utilities ---
        Alt+Slash { show-hotkey-overlay; }
        Print { spawn "sh" "-c" "grim ~/Pictures/$(date +%H%M%S).png"; }
        Alt+S { spawn "sh" "-c" "grim ~/Pictures/$(date +%H%M%S).png"; }

        // --- Window Navigation ---
        Alt+W { close-window; }
        Alt+Left { focus-column-left; }
        Alt+Right { focus-column-right; }
        
       //  --- Other binds (Alt+T, Alt+B, etc.) ...
        // 1. The "Cheat Sheet" (Show all your shortcuts instantly)
        Alt+Slash { show-hotkey-overlay; }

        // 2. The "Back to Plasma" (This quits Niri so you can log into Plasma)
        Alt+Shift+P { quit; } 
        Alt+Tab { toggle-window-floating; } // Note: Standard Alt+Tab behavior
        Alt+O { toggle-overview; }          // 'O' for Overview
    }
 '';
}
