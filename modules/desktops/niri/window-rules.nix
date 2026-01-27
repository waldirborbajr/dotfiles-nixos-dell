# modules/desktops/niri/window-rules.nix
# Window-specific rules (floating, sizing, etc)
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  
  windowRulesConfig = ''
    // ============================================
    // WINDOW RULES
    // ============================================
    window-rule {
      match app-id=r#"^org\.gnome\.Calculator$"#
      default-column-width { fixed 400; }
      open-floating true
    }

    window-rule {
      match app-id=r#"^pavucontrol$"#
      default-column-width { fixed 600; }
      open-floating true
    }

    window-rule {
      match app-id=r#"^nm-connection-editor$"#
      default-column-width { fixed 500; }
      open-floating true
    }

    window-rule {
      match app-id=r#"^org\.gnome\.FileRoller$"#
      default-column-width { fixed 800; }
    }

    window-rule {
      match app-id=r#"^imv$"#
      default-column-width { proportion 0.8; }
    }

    window-rule {
      match app-id=r#"^mpv$"#
      default-column-width { proportion 0.8; }
    }

    window-rule {
      match title=r#"^Picture-in-Picture$"#
      open-floating true
      open-on-output "eDP-1"
    }
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/window-rules.kdl".text = windowRulesConfig;
}
