{ config, pkgs, ... }:

{
  environment.etc."niri/config.kdl".text = ''
    // --- Layout & Styling ---
    layout {
        gaps 12
        center-focused-column "never"
        
        default-column-width { proportion 0.25; }
      focus-ring {
            width 10            // Doubled from 5 to 10 for visibility
            active-color "#00e5ff"   // Electric Cyan (High contrast)
            inactive-color "#1a237e" // Deep Navy (Fades into background)
            
            // Optional: Adds a subtle glow if your Niri version supports it
            // active-gradient from="#00e5ff" to="#74b2ff" angle=45
        }  
    }

    // --- Startup Services ---
    // This stops Plasma services so they don't fight Niri for your screen
    spawn-at-startup "sh" "-c" "systemctl --user stop plasma-plasmashell.service plasma-krunner.service plasma-kded6.service || true"
    
    spawn-at-startup "waybar"
    spawn-at-startup "alacritty"

    // --- Window Rules ---
    window-rule {
        match app-id="brave"
        default-column-width { proportion 0.5; } 
    }

    window-rule {
        match app-id="logseq"
        default-column-width { proportion 0.333; }
    }

    // --- Keybindings ---
    // We are leaving this section EMPTY to use Niri's built-in defaults (Super/Mod key).
    // Press 'Mod + /' in-game to see the full list of default shortcuts.
    binds {
        // --- The "Cheat Sheet" (Fixes your Mod + / problem) ---
        Mod+Slash { show-hotkey-overlay; }

        // --- Essential Navigation (Niri Defaults) ---
        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Return { spawn "alacritty"; }
        Mod+D     { spawn "fuzzel"; }
        Mod+Q     { close-window; }
        Mod+T      { spawn "foot"; }

        
        binds {
        // This is the correct "Internal" call for the sodiboo flake
        Mod+Slash { show-hotkey-overlay; }

        Mod+D { spawn "fuzzel"; }
        Mod+Enter { spawn "alacritty"; }
        Mod+Q { close-window; }
        
        // Let's add the "Electric Cyan" reload shortcut
        Mod+Shift+R { spawn "niri" "msg" "action" "load-config-file"; }
    }
        
        // --- System ---
        Mod+Shift+E { quit; }
        Mod+Shift+R { spawn "niri" "msg" "action" "load-config-file"; }
    }
  '';
}
