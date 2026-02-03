# modules/desktops/niri/layout.nix
# Layout configuration (gaps, borders, focus-ring, cursor, etc)
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  # Catppuccin Mocha colors
  cat = {
    mauve = "cba6f7";
    surface1 = "45475a";
  };
  hex = c: "#${c}";

  layoutConfig = ''
    // ============================================
    // LAYOUT CONFIGURATION
    // ============================================
    layout {
      gaps 14
      center-focused-column "never"
      
      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }
      
      focus-ring {
        width 3
        active-color "#7fc8ff"
        inactive-color "#282c34"
      }

      border {
        off
      }

      shadow {
        on
        softness 30
        spread 5
        offset x=0 y=5
        color "#0007"
      }

      struts {
        left 0
        right 0
        top 0
        bottom 0
      }
    }

    // ============================================
    // CURSOR CONFIGURATION
    // ============================================
    cursor {
      xcursor-theme "Adwaita"
      xcursor-size 24
      // Hide cursor when typing; also hides cursor from screenshots
      hide-when-typing
    }

    // ============================================
    // GESTURES
    // ============================================
    gestures {
      hot-corners {
        off // Disables only the top-left corner
      }
    }

    // ============================================
    // SCREENSHOT PATH
    // ============================================
    screenshot-path "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png"

    // ============================================
    // HOTKEY OVERLAY
    // ============================================
    hotkey-overlay {
      skip-at-startup
    }

    // ============================================
    // ENVIRONMENT VARIABLES
    // ============================================
    environment {
      DISPLAY ":1"
      _JAVA_AWT_WM_NONREPARENTING "1"
      QT_QPA_PLATFORM "wayland"
      MOZ_ENABLE_WAYLAND "1"
      NIXOS_OZONE_WL "1"
    }

    // ============================================
    // STARTUP APPLICATIONS
    // ============================================
    spawn-at-startup "swayidle" "-w" "timeout" "600" "niri msg action power-off-monitors"
    spawn-at-startup "waypaper" "--backend" "swaybg" "--restore"
    spawn-sh-at-startup "sleep 2 && swaybg -i ~/.config/niri/wallpaper.svg -m fill || true"
    // spawn-sh-at-startup "dms run"  // DMS disabled
    spawn-at-startup "/usr/bin/emacs" "--daemon"
    spawn-at-startup "mako"
    spawn-at-startup "waybar"
    spawn-at-startup "wl-paste" "--watch" "cliphist" "store"
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/layout.kdl".text = layoutConfig;
}
