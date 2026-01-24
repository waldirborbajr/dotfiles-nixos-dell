# modules/apps/niri.nix
{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName or "unknown";
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  # Catppuccin Mocha palette (hex WITHOUT '#')
  cat = {
    rosewater = "f5e0dc";
    flamingo = "f2cdcd";
    pink = "f5c2e7";
    mauve = "cba6f7";
    red = "f38ba8";
    maroon = "eba0ac";
    peach = "fab387";
    yellow = "f9e2af";
    green = "a6e3a1";
    teal = "94e2d5";
    sky = "89dceb";
    sapphire = "74c7ec";
    blue = "89b4fa";
    lavender = "b4befe";
    text = "cdd6f4";
    subtext1 = "bac2de";
    subtext0 = "a6adc8";
    overlay2 = "9399b2";
    overlay1 = "7f849c";
    overlay0 = "6c7086";
    surface2 = "585b70";
    surface1 = "45475a";
    surface0 = "313244";
    base = "1e1e2e";
    mantle = "181825";
    crust = "11111b";
  };
  hex = c: "#${c}";
  term = "alacritty";
  menu = "fuzzel";
in
lib.mkIf isMacbook {
  # Ativa Niri + configurações principais
  programs.niri = {
    enable = true;
    package = pkgs.niri;  # ou pkgs.unstable.niri para bleeding edge

    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            variant = "";
          };
          repeat-delay = 250;
          repeat-rate = 35;
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };

      layout = {
        gaps = 8;
        border = {
          width = 2;
          active-color = hex cat.mauve;
          inactive-color = hex cat.surface1;
          urgent-color = hex cat.red;
        };
      };

      animations = {
        enabled = true;
        workspace-switch.duration-ms = 140;
        window-open-close.duration-ms = 140;
      };

      # Autostart (spawn-at-startup)
      spawn-at-startup = [
        "mako"
        "waybar"
        term
      ];

      binds = {
        mod = "Super";

        # Launcher / terminal
        "Super+Return" = { spawn = term; };
        "Super+D" = { spawn = menu; };
        "Super+Shift+E" = "quit";

        # Screenshots
        "Print" = { spawn = "sh -lc 'grim -g \"$(slurp)\" - | swappy -f -'"; };
        "Super+Print" = { spawn = "sh -lc 'grim - | swappy -f -'"; };

        # Focus (vim keys)
        "Super+H" = "focus left";
        "Super+J" = "focus down";
        "Super+K" = "focus up";
        "Super+L" = "focus right";

        # Move windows
        "Super+Shift+H" = "move left";
        "Super+Shift+J" = "move down";
        "Super+Shift+K" = "move up";
        "Super+Shift+L" = "move right";

        # Workspaces 1..9
        "Super+1" = "workspace 1";
        "Super+2" = "workspace 2";
        "Super+3" = "workspace 3";
        "Super+4" = "workspace 4";
        "Super+5" = "workspace 5";
        "Super+6" = "workspace 6";
        "Super+7" = "workspace 7";
        "Super+8" = "workspace 8";
        "Super+9" = "workspace 9";

        "Super+Shift+1" = "move-to-workspace 1";
        "Super+Shift+2" = "move-to-workspace 2";
        "Super+Shift+3" = "move-to-workspace 3";
        "Super+Shift+4" = "move-to-workspace 4";
        "Super+Shift+5" = "move-to-workspace 5";
        "Super+Shift+6" = "move-to-workspace 6";
        "Super+Shift+7" = "move-to-workspace 7";
        "Super+Shift+8" = "move-to-workspace 8";
        "Super+Shift+9" = "move-to-workspace 9";

        "Super+F" = "toggle-fullscreen";
        "Super+Space" = "toggle-floating";
      };

      window-rules = [
        {
          match.app-id = "org.gnome.Calculator";
          floating = true;
        }
      ];
    };
  };

  # Waybar (minimal, Catppuccin Mocha)
  xdg.configFile = {
    "waybar/config.jsonc".text = ''
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

    "waybar/style.css".text = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 11px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }
      window#waybar {
        background: rgba(30, 30, 46, 0.95);
        color: #cdd6f4;
      }
      #clock, #pulseaudio, #network, #battery, #tray, #workspaces {
        padding: 0 10px;
        margin: 6px 6px;
        background: #313244;
        border-radius: 10px;
      }
      #workspaces button {
        padding: 0 8px;
        margin: 0 2px;
        background: transparent;
        color: #a6adc8;
      }
      #workspaces button.active {
        color: #1e1e2e;
        background: #cba6f7;
        border-radius: 8px;
      }
    '';
  };

  # Mako (notifications, Catppuccin Mocha)
  xdg.configFile."mako/config".text = ''
    background-color=#1e1e2ee6
    text-color=#cdd6f4
    border-color=#cba6f7
    progress-color=over #45475a
    border-size=2
    border-radius=10
    padding=10
    default-timeout=5000
    font=JetBrainsMono Nerd Font 10
  '';

  # Fuzzel (launcher, Catppuccin Mocha)
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=11
    prompt="> "
    width=40
    lines=12

    [colors]
    background=#1e1e2eee
    text=#cdd6f4ff
    match=#cba6f7ff
    selection=#45475aff
    selection-text=#cdd6f4ff
    border=#cba6f7ff
  '';

  # Pacotes necessários (só instalados no macbook)
  home.packages = with pkgs; [
    niri
    waybar
    mako
    fuzzel
    alacritty
    wl-clipboard
    grim
    slurp
    swappy
    playerctl
  ];

  # Wayland essentials (movidos para cá)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };
}
