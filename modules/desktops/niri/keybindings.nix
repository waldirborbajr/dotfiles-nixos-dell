# modules/desktops/niri/keybindings.nix
# Keybindings configuration
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  
  # Applications
  term = "alacritty";
  menu = "fuzzel";
  browser = "firefox";
  fileManager = "yazi";
  
  keybindingsConfig = ''
    // ============================================
    // KEYBINDINGS
    // ============================================
    binds {
      // Mod = Super (Windows key)

      // ========================================
      // APPLICATIONS
      // ========================================
      Mod+Return { spawn "${term}"; }
      Mod+D { spawn "${menu}"; }
      Mod+B { spawn "${browser}"; }
      Mod+E { spawn "${term}" "-e" "${fileManager}"; }
      
      // ========================================
      // SESSION / COMPOSITOR
      // ========================================
      Mod+Shift+E { quit; }
      Mod+Shift+P { power-off-monitors; }
      Mod+Shift+Ctrl+T { toggle-debug-tint; }

      // ========================================
      // SCREENSHOTS
      // ========================================
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }
      
      // Screenshot with tools
      Mod+Print { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }
      Mod+Shift+Print { spawn "sh" "-c" "grim - | swappy -f -"; }

      // ========================================
      // WINDOW FOCUS (VIM-STYLE)
      // ========================================
      Mod+H { focus-column-left; }
      Mod+J { focus-window-down; }
      Mod+K { focus-window-up; }
      Mod+L { focus-column-right; }

      Mod+Left { focus-column-left; }
      Mod+Down { focus-window-down; }
      Mod+Up { focus-window-up; }
      Mod+Right { focus-column-right; }

      // ========================================
      // WINDOW MOVEMENT
      // ========================================
      Mod+Shift+H { move-column-left; }
      Mod+Shift+J { move-window-down; }
      Mod+Shift+K { move-window-up; }
      Mod+Shift+L { move-column-right; }

      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Down { move-window-down; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Right { move-column-right; }

      // ========================================
      // WINDOW SIZING
      // ========================================
      Mod+R { switch-preset-column-width; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+C { center-column; }

      // Fine-grained sizing
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      // ========================================
      // WORKSPACES
      // ========================================
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      // Move windows to workspaces
      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }
      Mod+Shift+6 { move-column-to-workspace 6; }
      Mod+Shift+7 { move-column-to-workspace 7; }
      Mod+Shift+8 { move-column-to-workspace 8; }
      Mod+Shift+9 { move-column-to-workspace 9; }

      // Workspace navigation
      Mod+Tab { focus-workspace-down; }
      Mod+Shift+Tab { focus-workspace-up; }
      Mod+Ctrl+H { focus-workspace-down; }
      Mod+Ctrl+L { focus-workspace-up; }
      Mod+Ctrl+Left { focus-workspace-down; }
      Mod+Ctrl+Right { focus-workspace-up; }

      // Move to monitors
      Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

      // ========================================
      // WINDOW MANAGEMENT
      // ========================================
      Mod+Q { close-window; }
      Mod+Shift+Space { toggle-window-floating; }
      
      // Consume or expel window into/from column
      Mod+BracketLeft { consume-window-into-column; }
      Mod+BracketRight { expel-window-from-column; }

      // ========================================
      // MEDIA KEYS
      // ========================================
      XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"; }
      XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"; }
      XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86AudioMicMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

      XF86MonBrightnessUp { spawn "brightnessctl" "set" "5%+"; }
      XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

      XF86AudioPlay { spawn "playerctl" "play-pause"; }
      XF86AudioPause { spawn "playerctl" "play-pause"; }
      XF86AudioNext { spawn "playerctl" "next"; }
      XF86AudioPrev { spawn "playerctl" "previous"; }

      // ========================================
      // SPECIAL
      // ========================================
      Mod+Shift+Slash { show-hotkey-overlay; }
    }
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/keybindings.kdl".text = keybindingsConfig;
}
