# modules/desktops/niri/niri.nix
{ config, pkgs, lib, ... }:

let
  # Catppuccin Mocha palette (hex without #)
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

  # GDM session wrapper (Nix-managed, available on PATH)
  niriSession = pkgs.writeShellScriptBin "niri-session" ''
    set -euo pipefail

    # Session identity (helps portals / apps)
    export XDG_CURRENT_DESKTOP=niri
    export XDG_SESSION_DESKTOP=niri

    # Wayland-friendly defaults
    export NIXOS_OZONE_WL=1
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland

    # Optional: ensure a user runtime exists (usually already true under GDM)
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

    # Start niri
    exec ${pkgs.niri}/bin/niri
  '';
in
{
  ############################################
  # Packages used by Niri session
  ############################################
  environment.systemPackages = with pkgs; [
    niri

    # Terminal / launcher / notifications
    foot
    fuzzel
    mako

    # Bar / tray
    waybar

    # Clipboard / screenshots
    wl-clipboard
    grim
    slurp
    swappy

    # Media keys
    playerctl

    # GDM session wrapper
    niriSession
  ];

  ############################################
  # Make Niri show up in GDM (gear menu)
  ############################################
  environment.etc."wayland-sessions/niri.desktop".text = ''
    [Desktop Entry]
    Name=Niri
    Comment=Wayland compositor (niri)
    Exec=/run/current-system/sw/bin/niri-session
    Type=Application
  '';

  ############################################
  # Portals (screen share, file pickers, etc)
  ############################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  ############################################
  # Base services for Wayland desktops
  ############################################
  security.polkit.enable = true;
  services.dbus.enable = true;

  ############################################
  # Canonical configs (Nix-managed): /etc/xdg/*
  ############################################

  # Niri main config (KDL)
  environment.etc."xdg/niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "br"
          variant "abnt2"
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
    spawn-at-startup "foot" "--title" "terminal"

    binds {
      mod "Super"

      bind "Super+Return" spawn "foot"
      bind "Super+D"      spawn "fuzzel"
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

  ############################################
  # Catppuccin Mocha configs for common tools
  ############################################

  # Mako notifications
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

  # Foot terminal
  environment.etc."xdg/foot/foot.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=11
    dpi-aware=yes

    [colors]
    background=${cat.base}
    foreground=${cat.text}

    regular0=${cat.crust}
    regular1=${cat.red}
    regular2=${cat.green}
    regular3=${cat.yellow}
    regular4=${cat.blue}
    regular5=${cat.mauve}
    regular6=${cat.teal}
    regular7=${cat.subtext1}

    bright0=${cat.surface2}
    bright1=${cat.red}
    bright2=${cat.green}
    bright3=${cat.yellow}
    bright4=${cat.blue}
    bright5=${cat.mauve}
    bright6=${cat.teal}
    bright7=${cat.text}
  '';

  # Fuzzel launcher
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

  # Waybar config (JSONC)
  environment.etc."xdg/waybar/config.jsonc".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 30,
      "spacing": 8,

      "modules-left": ["niri/workspaces"],
      "modules-center": ["clock"],
      "modules-right": ["pulseaudio", "network", "battery", "tray"],

      "niri/workspaces": {
        "disable-scroll": false,
        "format": "{name}"
      },

      "clock": { "format": "{:%a %d/%m %H:%M}" },

      "pulseaudio": { "format": " {volume}%", "format-muted": "󰖁 muted" },
      "network": {
        "format-wifi": " {essid} ({signalStrength}%)",
        "format-ethernet": "󰈀 {ipaddr}",
        "format-disconnected": "󰖪 offline",
        "tooltip": true
      },
      "battery": {
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "states": { "warning": 25, "critical": 12 },
        "format-icons": ["","","","",""]
      }
    }
  '';

  # Waybar style (Catppuccin-ish)
  environment.etc."xdg/waybar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font", monospace;
      font-size: 11px;
      border: none;
      min-height: 0;
    }

    window#waybar {
      background: rgba(30, 30, 46, 0.95);
      color: ${hex cat.text};
    }

    #clock,
    #pulseaudio,
    #network,
    #battery,
    #tray,
    #workspaces {
      padding: 0 10px;
      margin: 6px 4px;
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
      color: ${hex cat.mauve};
      background: ${hex cat.surface1};
      border-radius: 8px;
    }

    tooltip {
      background: ${hex cat.base};
      border: 1px solid ${hex cat.surface1};
      border-radius: 10px;
      color: ${hex cat.text};
    }

    tooltip label {
      padding: 6px;
    }
  '';
}
```0