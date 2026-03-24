{ config, pkgs, ... }:

{
  environment.etc."niri/config.kdl".text = ''
    layout {
        gaps 12
        center-focused-column "never"

        preset-column-widths {
            proportion 0.25   
            proportion 0.333  
            proportion 0.5    
            proportion 0.666  
        }

        default-column-width { proportion 0.5; }

        // Defining the block turns it on—no "enable" keyword needed!
        focus-ring {
            width 2
            active-color "#74b2ff"   // Kona Blue
            inactive-color "#475da7" // Darker blue
        }
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

        // Stacking
        Alt+V { consume-window-into-column; }
        Alt+Shift+V { expel-window-from-column; }
        
        // --- Navigation ---
        Alt+Left  { focus-column-left; }
        Alt+Right { focus-column-right; }
        Alt+Slash { show-hotkey-overlay; }
        Alt+Comma { switch-preset-column-width; } 
        Alt+A     { toggle-overview; }   

        // --- Manual Sizing ---
        Alt+Minus { set-column-width "-10%"; }
        Alt+Equal { set-column-width "+10%"; }
    }
  '';
}
