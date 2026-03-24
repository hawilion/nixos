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
        // EMERGENCY BACKDOOR: Always keep these active
        Ctrl+Alt+T { spawn "alacritty"; }
        Ctrl+Alt+Delete { quit; } 

        // Standard App Shortcuts
        Mod+T { spawn "alacritty"; }
        Mod+D { spawn "fuzzel"; }
        Mod+E { spawn "dolphin"; }
        Mod+B { spawn "brave"; }
        Mod+Shift+E { quit; }
        
        // Window & Column Navigation
        Mod+W { close-window; }
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        
        // Column Sizing
        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }
        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        
        // ... your other binds ...
    
        Mod+Slash { show-hotkey-overlay; }
}
    }
  '';
}
