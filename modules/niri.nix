{ config, pkgs, ... }:

{
  # This tells Nix: "Everything inside these quotes is just text for Niri"
environment.etc."niri/config.kdl".text  = ''
layout {
    gaps 12
    center-focused-column "never"

    preset-column-widths {
        proportion 0.25   // Fits 4 windows (Press Alt+R to cycle)
        proportion 0.333  // Fits 3 windows
        proportion 0.5    // Fits 2 windows
        proportion 0.666  // Two thirds screen
    }

    default-column-width { proportion 0.5; }
}

// Startup commands
spawn-at-startup "sh" "-c" "systemctl --user stop plasma-plasmashell.service plasma-krunner.service plasma-kded6.service || true"
spawn-at-startup "waybar"
spawn-at-startup "alacritty"

binds {
    // --- System Controls ---
    Ctrl+Alt+Delete { quit; }
    Alt+Shift+P { quit; } 

    // --- App Launchers ---
    Alt+T { spawn "alacritty"; }
    Alt+B { spawn "brave"; }
    Alt+D { spawn "fuzzel"; }
    Alt+L { spawn "logseq"; }

    // --- Window Management ---
    Alt+W { close-window; }
    Alt+R { switch-preset-column-width; }
    Alt+F { maximize-column; }

    // This is the most stable "unified" command for vertical stacking
    Alt+V { consume-window-into-column; }
    Alt+Shift+V { expel-window-from-column; }
    
    // --- Navigation ---
    Alt+Left  { focus-column-left; }
    Alt+Right { focus-column-right; }
    Alt+Slash { show-hotkey-overlay; }
    
    // --- Manual Sizing ---
    Alt+Minus { set-column-width "-10%"; }
    Alt+Equal { set-column-width "+10%"; }
}

    '';
}
