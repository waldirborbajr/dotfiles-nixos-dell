# modules/desktops/niri/niri.nix
#
# Niri (Wayland compositor) for NixOS (no Home-Manager)
# - Session is declared by NixOS (shows up in GDM session list)
# - Configs are Nix-managed in /etc/xdg + optional ~/.config symlinks
# - IMPORTANT: do NOT set XDG_RUNTIME_DIR manually (systemd/logind manages it)

{ config, pkgs, lib, ... }:

let
  # Catppuccin Mocha palette (hex WITHOUT '#')
  cat = {
    rosewater = "f5e0dc";
    flamingo  = "f2cdcd";
    pink      = "f5c2e7";
    mauve     = "cba6f7";
    red       = "f38ba8";
    maroon    = "eba0ac";
    peach     = "fab387";
    yellow    = "f9e2af";
    green     = "a6e3a1";
    teal      = "94e2d5";
    sky       = "89dceb";
    sapphire  = "74c7ec";
    blue      = "89b4fa";
    lavender  = "b4befe";
    text      = "cdd6f4";
    subtext1  = "bac2de";
    subtext0  = "a6adc8";
    overlay2  = "9399b2";
    overlay1  = "7f849c";
    overlay0  = "6c7086";
    surface2  = "585b70";
    surface1  = "45475a";
    surface0  = "313244";
    base      = "1e1e2e";
    mantle    = "181825";
    crust     = "11111b";
  };

  hex = c: "#${c}";

  term = "alacritty";
  menu = "fuzzel";
in
{
  ##############################################################################
  # Niri: managed by NixOS
  ##############################################################################
  programs.niri.enable = true;

  # Ensure GDM/SDDM can discover the session
  services.displayManager.sessionPackages = [
    pkgs.niri
  ];

  # Explicit session file (required when nixpkgs doesn't ship one)
  environment.etc."wayland-sessions/niri.desktop".text = ''
    [Desktop Entry]
    Name=Niri
    Comment=Niri Wayland Compositor
    Exec=${pkgs.niri}/bin/niri
    Type=Application
    DesktopNames=niri
  '';

  ##############################################################################
  # Wayland essentials
  ##############################################################################
  services.dbus.enable = true;
  security.polkit.enable = true;

  # Useful for Wayland apps (don’t force XDG_SESSION_TYPE globally).
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };

  ##############################################################################
  # Packages (keep it lean)
  ##############################################################################
  environment.systemPackages = with pkgs; [
    # UX
    waybar
    mako
    fuzzel

    # Terminal (explicit so binds work)
    alacritty

    # Clipboard / screenshots
    wl-clipboard
    grim
    slurp
    swappy

    # Optional: audio keys, media control
    playerctl
  ];

  ##############################################################################
  # Portals (screen share, file picker, etc.)
  # - Since you also have GNOME installed, keep gtk portal.
  ##############################################################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  ##############################################################################
  # Nix-managed configs under /etc/xdg
  ##############################################################################

  # Niri main config (KDL)
  environment.etc."xdg/niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "us"
          variant ""
        }
        repeat-delay 250
        repeat-rate 35
      }

      touchpad {
        tap true
        natural-scroll true
      }
    }

    layout {
      gaps 8
      border {
        width 2
        active-color "${hex cat.mauve}"
        inactive-color "${hex cat.surface1}"
        urgent-color "${hex cat.red}"
      }
    }

    animations {
      enabled true
      workspace-switch { duration-ms 140 }
      window-open-close { duration-ms 140 }
    }

    # Autostart
    spawn-at-startup "mako"
    spawn-at-startup "waybar"
    spawn-at-startup "${term}"

    binds {
      mod "Super"

      # Launcher / terminal
      bind "Super+Return" spawn "${term}"
      bind "Super+D"      spawn "${menu}"
      bind "Super+Shift+E" quit

      # Screenshots
      bind "Print"       spawn "sh" "-lc" "grim -g \"$(slurp)\" - | swappy -f -"
      bind "Super+Print" spawn "sh" "-lc" "grim - | swappy -f -"

      # Focus (vim keys)
      bind "Super+H" focus left
      bind "Super+J" focus down
      bind "Super+K" focus up
      bind "Super+L" focus right

      # Move windows
      bind "Super+Shift+H" move left
      bind "Super+Shift+J" move down
      bind "Super+Shift+K" move up
      bind "Super+Shift+L" move right

      # Workspaces 1..9
      bind "Super+1" workspace 1
      bind "Super+2" workspace 2
      bind "Super+3" workspace 3
      bind "Super+4" workspace 4
      bind "Super+5" workspace 5
      bind "Super+6" workspace 6
      bind "Super+7" workspace 7
      bind "Super+8" workspace 8
      bind "Super+9" workspace 9

      bind "Super+Shift+1" move-to-workspace 1
      bind "Super+Shift+2" move-to-workspace 2
      bind "Super+Shift+3" move-to-workspace 3
      bind "Super+Shift+4" move-to-workspace 4
      bind "Super+Shift+5" move-to-workspace 5
      bind "Super+Shift+6" move-to-workspace 6
      bind "Super+Shift+7" move-to-workspace 7
      bind "Super+Shift+8" move-to-workspace 8
      bind "Super+Shift+9" move-to-workspace 9

      bind "Super+F" toggle-fullscreen
      bind "Super+Space" toggle-floating
    }

    window-rules {
      rule {
        match app-id "org.gnome.Calculator"
        floating true
      }
    }
  '';

  # Mako (notifications)
  environment.etc."xdg/mako/config".text = ''
    background-color=${hex cat.base}E6
    text-color=${hex cat.text}
    border-color=${hex cat.mauve}
    progress-color=over ${hex cat.surface1}
    border-size=2
    border-radius=10
    padding=10
    default-timeout=5000
    font=JetBrainsMono Nerd Font 10
  '';

  # Fuzzel (launcher)
  environment.etc."xdg/fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=11
    prompt="> "
    width=40
    lines=12

    [colors]
    background=${cat.base}ee
    text=${cat.text}ff
    match=${cat.mauve}ff
    selection=${cat.surface1}ff
    selection-text=${cat.text}ff
    border=${cat.mauve}ff
  '';

  # Waybar (minimal)
  environment.etc."xdg/waybar/config.jsonc".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 30,
      "spacing": 8,

      "modules-left": ["niri/workspaces"],
      "modules-center": ["clock"],
      "modules-right": ["pulseaudio", "network", "battery", "tray"],

      "clock": { "format": "{:%a %d/%m %H:%M}" },

      "pulseaudio": { "format": " {volume}%", "format-muted": "󰖁 muted" },
      "network": { "format-wifi": " {signalStrength}%", "format-ethernet": "󰈀 {ipaddr}", "format-disconnected": "󰖪" },
      "battery": { "format": "{capacity}% " }
    }
  '';

  environment.etc."xdg/waybar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 11px;
      border: none;
      border-radius: 0;
      min-height: 0;
    }

    window#waybar {
      background: rgba(30, 30, 46, 0.95);
      color: ${hex cat.text};
    }

    #clock, #pulseaudio, #network, #battery, #tray, #workspaces {
      padding: 0 10px;
      margin: 6px 6px;
      background: ${hex cat.surface0};
      border-radius: 10px;
    }

    #workspaces button {
      padding: 0 8px;
      margin: 0 2px;
      background: transparent;
      color: ${hex cat.subtext1};
    }

    #workspaces button.active {
      color: ${hex cat.base};
      background: ${hex cat.mauve};
      border-radius: 8px;
    }
  '';

  ##############################################################################
  # Optional: symlink /etc/xdg configs into ~/.config (no Home-Manager)
  # This helps apps that ONLY read ~/.config and ignore XDG_CONFIG_DIRS.
  ##############################################################################
  systemd.user.services."xdg-config-links-niri" = {
    description = "Symlink Niri-related configs from /etc/xdg to ~/.config";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      mkdir -p "$HOME/.config/niri" "$HOME/.config/waybar" "$HOME/.config/mako" "$HOME/.config/fuzzel"

      # Niri
      [ -e "$HOME/.config/niri/config.kdl" ] || ln -s /etc/xdg/niri/config.kdl "$HOME/.config/niri/config.kdl"

      # Waybar
      [ -e "$HOME/.config/waybar/config.jsonc" ] || ln -s /etc/xdg/waybar/config.jsonc "$HOME/.config/waybar/config.jsonc"
      [ -e "$HOME/.config/waybar/style.css" ] || ln -s /etc/xdg/waybar/style.css "$HOME/.config/waybar/style.css"

      # Mako
      [ -e "$HOME/.config/mako/config" ] || ln -s /etc/xdg/mako/config "$HOME/.config/mako/config"

      # Fuzzel
      [ -e "$HOME/.config/fuzzel/fuzzel.ini" ] || ln -s /etc/xdg/fuzzel/fuzzel.ini "$HOME/.config/fuzzel/fuzzel.ini"
    '';
  };
}