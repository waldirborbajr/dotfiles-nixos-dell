# modules/desktops/niri/window-rules.nix
# Window-specific rules (floating, sizing, etc)
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  windowRulesConfig = ''
    // ============================================
    // WINDOW RULES
    // ============================================
    
    // Enable rounded corners and transparency for all windows
    window-rule {
      geometry-corner-radius 6
      clip-to-geometry true
    }
    
    // Alacritty - 60% width with transparency
    window-rule {
      match app-id=r#"^Alacritty$"#
      default-column-width { proportion 0.6; }
      opacity 0.75
    }

    // Applications that should open maximized
    window-rule {
      match app-id=r#"audacity$"#
      match app-id=r#"brave-browser$"#
      match app-id=r#"discord$"#
      match app-id=r#"gimp$"#
      match app-id=r#"kdenlive$"#
      match app-id=r#"qutebrowser$"#
      match app-id=r#"tasty.javafx.launcher.LauncherFxApp$"# title="^dt.*"
      match app-id=r#"tasty.javafx.launcher.LauncherFxApp$"# title="^tastytrade v.*"
      open-maximized true
    }

    // Applications that should float
    window-rule {
      match app-id=r#"qalculate-gtk$"#
      match app-id=r#"tasty.javafx.launcher.LauncherFxApp$"# title="Dashboard"
      match app-id=r#"tasty.javafx.launcher.LauncherFxApp$"# title="tastytrade - Portfolio Report"
      open-floating true
    }

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
