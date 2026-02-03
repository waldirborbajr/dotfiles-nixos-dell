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
      // Keyboard layout switching (US ⟷ US-intl)
      Mod+Slash { switch-layout "next"; }
      // Mod = Super (Windows key)

      // ========================================
      // APPLICATIONS
      // ========================================
      Mod+Return hotkey-overlay-title="Open terminal: alacritty" { spawn "${term}"; }
      Mod+Shift+Return hotkey-overlay-title="Run launcher: rofi" { spawn "rofi" "-show" "drun" "-show-icons"; }
      Mod+D { spawn "${menu}"; }
      Mod+B { spawn "${browser}"; }
      Mod+E hotkey-overlay-title="Open emacs" { spawn "emacsclient" "-c" "-a" "emacs"; }
      Mod+W hotkey-overlay-title="Open browser: brave" { spawn "brave"; }
      Mod+Alt+Minus hotkey-overlay-title="Lock screen: swaylock" { spawn "swaylock"; }
      
      // Launcher and utilities (Fuzzel + Mako replacements for DMS)
      Mod+Space hotkey-overlay-title="App launcher: fuzzel" { spawn "fuzzel"; }
      Mod+N hotkey-overlay-title="Clear notifications" { spawn "makoctl" "dismiss" "-a"; }
      Mod+V hotkey-overlay-title="Clipboard manager" { spawn "sh" "-c" "cliphist list | fuzzel -d | cliphist decode | wl-copy"; }
      
      // ========================================
      // SESSION / COMPOSITOR
      // ========================================
      Mod+Shift+Q hotkey-overlay-title="Quit out of niri" { quit; }
      Mod+Shift+E { quit; }
      Ctrl+Alt+P { power-off-monitors; }
      Mod+Shift+P { power-off-monitors; }
      Mod+Shift+Ctrl+T { toggle-debug-tint; }
      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

      // ========================================
      // SCREENSHOTS
      // ========================================
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }
      Mod+apostrophe { screenshot-screen; }
      Mod+Alt+apostrophe { screenshot-window; }
      Mod+Shift+apostrophe { screenshot; }
      
      // Screenshot with tools
      Mod+Print { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }
      Mod+Shift+Print { spawn "sh" "-c" "grim - | swappy -f -"; }

      // ========================================
      // OVERVIEW
      // ========================================
      Mod+O repeat=false hotkey-overlay-title="Toggle overview" { toggle-overview; }

      // ========================================
      // WINDOW FOCUS (VIM-STYLE)
      // ========================================
      Mod+H hotkey-overlay-title="Focus column left" { focus-column-left; }
      Mod+J hotkey-overlay-title="Focus window/workspace down" { focus-window-or-workspace-down; }
      Mod+K hotkey-overlay-title="Focus window/workspace up" { focus-window-or-workspace-up; }
      Mod+L hotkey-overlay-title="Focus column right" { focus-column-right; }

      Mod+Left { focus-column-left; }
      Mod+Down { focus-window-or-workspace-down; }
      Mod+Up { focus-window-or-workspace-up; }
      Mod+Right { focus-column-right; }

      // Focus first/last column
      Mod+Home { focus-column-first; }
      Mod+End { focus-column-last; }

      // ========================================
      // WINDOW MOVEMENT
      // ========================================
      Mod+Shift+H { move-column-left-or-to-monitor-left; }
      Mod+Shift+J { move-column-to-workspace-down; }
      Mod+Shift+K { move-column-to-workspace-up; }
      Mod+Shift+L { move-column-right-or-to-monitor-right; }

      Mod+Shift+Left { move-column-left-or-to-monitor-left; }
      Mod+Shift+Down { move-window-down; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Right { move-column-right-or-to-monitor-right; }

      // Move to First/Last
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End { move-column-to-last; }

      // Move workspace itself
      Mod+Ctrl+U { move-workspace-down; }
      Mod+Ctrl+I { move-workspace-up; }

      // ========================================
      // WINDOW SIZING
      // ========================================
      Mod+R { switch-preset-column-width; }
      Mod+Shift+R { switch-preset-window-height; }
      Mod+Ctrl+R { reset-window-height; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+C { center-column; }
      Mod+Ctrl+C { center-visible-columns; }
      Mod+Ctrl+F { expand-column-to-available-width; }

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
      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Ctrl+6 { move-column-to-workspace 6; }
      Mod+Ctrl+7 { move-column-to-workspace 7; }
      Mod+Ctrl+8 { move-column-to-workspace 8; }
      Mod+Ctrl+9 { move-column-to-workspace 9; }

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

      // Mouse wheel workspace navigation
      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }

      // Mouse wheel column navigation
      Mod+WheelScrollRight { focus-column-right; }
      Mod+WheelScrollLeft { focus-column-left; }
      Mod+Ctrl+WheelScrollRight { move-column-right; }
      Mod+Ctrl+WheelScrollLeft { move-column-left; }

      // Shift+Scroll for horizontal navigation
      Mod+Shift+WheelScrollDown { focus-column-right; }
      Mod+Shift+WheelScrollUp { focus-column-left; }
      Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
      Mod+Ctrl+Shift+WheelScrollUp { move-column-left; }

      // Monitor focus
      Mod+Ctrl+Comma { focus-monitor-previous; }
      Mod+Ctrl+Period { focus-monitor-next; }

      // Move to monitors
      Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

      // ========================================
      // WINDOW MANAGEMENT
      // ========================================
      Mod+Q { close-window; }
      Mod+Shift+C repeat=false hotkey-overlay-title="Close window" { close-window; }
      
      // Floating windows
      Mod+Alt+V { toggle-window-floating; }
      Mod+Shift+V { switch-focus-between-floating-and-tiling; }
      Mod+Shift+Space { toggle-window-floating; }
      
      // Tabbed display
      Mod+T hotkey-overlay-title="Toggle tabbed display" { toggle-column-tabbed-display; }
      
      // Consume or expel window into/from column
      Mod+BracketLeft { consume-window-into-column; }
      Mod+BracketRight { expel-window-from-column; }
      Mod+Alt+H { consume-or-expel-window-left; }
      Mod+Alt+L { consume-or-expel-window-right; }

      // ========================================
      // MEDIA KEYS
      // ========================================
      XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
      XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
      XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

      XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

      XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
      XF86AudioStop allow-when-locked=true { spawn-sh "playerctl stop"; }
      XF86AudioPause allow-when-locked=true { spawn-sh "playerctl play-pause"; }
      XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }
      XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }

      // ========================================
      // SPECIAL
      // ========================================
      Mod+Shift+Slash hotkey-overlay-title="Show important bindings" { show-hotkey-overlay; }
    }
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/keybindings.kdl".text = keybindingsConfig;
}
