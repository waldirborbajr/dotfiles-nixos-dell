# modules/desktops/niri.nix
# Niri - Scrollable-tiling Wayland compositor
# Modern compositor with unique scrollable workspaces
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  # Use centralized theme colors
  # Access via config.catppuccin or fallback to Mocha
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
  
  # Applications
  term = "alacritty";
  menu = "fuzzel";
  browser = "firefox";
  fileManager = "yazi";

  # Niri config as KDL (Niri's native format)
  niriKdl = ''
    // ============================================
    // INPUT CONFIGURATION
    // ============================================
    input {
      keyboard {
        xkb {
          layout "us"
          variant ""
        }
        repeat-delay 250
        repeat-rate 35
        track-layout "global"
      }

      touchpad {
        tap
        natural-scroll
        dwt
        dwtp
        accel-speed 0.3
        accel-profile "adaptive"
        scroll-method "two-finger"
        click-method "clickfinger"
      }

      mouse {
        accel-speed 0.0
        accel-profile "flat"
      }

      tablet {
        map-to-output "eDP-1"
      }

      touch {
        map-to-output "eDP-1"
      }

      trackpoint {
        accel-speed 0.2
        accel-profile "adaptive"
      }

      focus-follows-mouse
      workspace-auto-back-and-forth
    }

    // ============================================
    // OUTPUT CONFIGURATION
    // ============================================
    output "eDP-1" {
      mode "1920x1080@60.000"
      scale 1.0
      transform "normal"
      position x=0 y=0
    }

    // ============================================
    // LAYOUT CONFIGURATION
    // ============================================
    layout {
      gaps 8
      center-focused-column "on-overflow"
      
      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }
      
      focus-ring {
        width 2
        active-color "${hex cat.mauve}"
        inactive-color "${hex cat.surface1}"
        // active-gradient from="${hex cat.mauve}" to="${hex cat.pink}" angle=45
      }

      border {
        off
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
    }

    // ============================================
    // PREFER NO CSD (use SSD)
    // ============================================
    prefer-no-csd

    // ============================================
    // SCREENSHOT PATH
    // ============================================
    screenshot-path "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png"

    // ============================================
    // ANIMATIONS
    // ============================================
    animations {
      slowdown 1.0
      
      workspace-switch {
        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
      }
      
      horizontal-view-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }
      
      window-open {
        duration-ms 150
        curve "ease-out-expo"
      }
      
      window-close {
        duration-ms 150
        curve "ease-out-quad"
      }
      
      window-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }
      
      window-resize {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }
      
      config-notification-open-close {
        spring damping-ratio=0.6 stiffness=1000 epsilon=0.001
      }
    }

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
      DISPLAY null
      QT_QPA_PLATFORM "wayland"
      MOZ_ENABLE_WAYLAND "1"
      NIXOS_OZONE_WL "1"
    }

    // ============================================
    // STARTUP APPLICATIONS
    // ============================================
    spawn-at-startup "mako"
    spawn-at-startup "waybar"
    spawn-at-startup "wl-paste" "--watch" "cliphist" "store"
    
    // ============================================
    // WINDOW RULES
    // ============================================
    window-rule {
      match app-id=r#"^org\.gnome\.Calculator$"#
      default-column-width { fixed 400; }
      open-floating
    }

    window-rule {
      match app-id=r#"^pavucontrol$"#
      default-column-width { fixed 600; }
      open-floating
    }

    window-rule {
      match app-id=r#"^nm-connection-editor$"#
      default-column-width { fixed 500; }
      open-floating
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
      open-floating
      open-on-output "eDP-1"
    }

    // ============================================
    // KEYBINDINGS
    // ============================================
    binds {
      // Mod key
      Mod { Super; }

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

    // ============================================
    // DEBUG (Performance monitoring)
    // ============================================
    debug {
      render-drm-device "/dev/dri/renderD128"
      
      // Uncomment to enable visual debug
      // dri-device "/dev/dri/card0"
      // disable-cursor-plane
      // wait-for-frame-completion-before-queueing
    }
  '';
in
lib.mkIf isMacbook {
  home.packages = with pkgs; [
    niri
    waybar
    mako
    fuzzel
    wl-clipboard
    cliphist
    grim
    slurp
    swappy
    playerctl
    brightnessctl
    pamixer
    pavucontrol
    networkmanagerapplet
  ];

  # Niri expects config at: ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".text = niriKdl;

  # ============================================
  # Waybar - Status bar optimized for Niri
  # ============================================
  xdg.configFile."waybar/config.jsonc".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 32,
      "spacing": 4,
      "margin-top": 6,
      "margin-left": 10,
      "margin-right": 10,
      
      "modules-left": [
        "niri/workspaces",
        "niri/window"
      ],
      
      "modules-center": [
        "clock"
      ],
      
      "modules-right": [
        "tray",
        "idle_inhibitor",
        "pulseaudio",
        "network",
        "cpu",
        "memory",
        "temperature",
        "backlight",
        "battery"
      ],

      "niri/workspaces": {
        "format": "{icon}",
        "format-icons": {
          "1": "󰮺",
          "2": "󰯻",
          "3": "󰯼",
          "4": "󰯽",
          "5": "󰯾",
          "6": "󰯿",
          "7": "󰰀",
          "8": "󰰁",
          "9": "󰰂",
          "active": "",
          "default": ""
        },
        "on-scroll-up": "niri msg action focus-workspace-down",
        "on-scroll-down": "niri msg action focus-workspace-up"
      },

      "niri/window": {
        "format": "{}",
        "max-length": 50,
        "icon": true,
        "icon-size": 16,
        "rewrite": {
          "(.*) — Mozilla Firefox": " $1",
          "(.*)Mozilla Firefox": " Firefox",
          "(.*) - Alacritty": " $1",
          "Alacritty": " Terminal"
        }
      },

      "clock": {
        "interval": 1,
        "format": "{:%a %d %b  %H:%M:%S}",
        "format-alt": "{:%Y-%m-%d %H:%M:%S}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>",
        "calendar": {
          "mode": "month",
          "mode-mon-col": 3,
          "weeks-pos": "right",
          "on-scroll": 1,
          "format": {
            "months": "<span color='#cba6f7'><b>{}</b></span>",
            "days": "<span color='#cdd6f4'><b>{}</b></span>",
            "weeks": "<span color='#a6adc8'><b>W{}</b></span>",
            "weekdays": "<span color='#f9e2af'><b>{}</b></span>",
            "today": "<span color='#f38ba8'><b><u>{}</u></b></span>"
          }
        }
      },

      "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
          "activated": "",
          "deactivated": ""
        },
        "tooltip-format-activated": "Idle inhibitor active",
        "tooltip-format-deactivated": "Idle inhibitor inactive"
      },

      "tray": {
        "icon-size": 16,
        "spacing": 8,
        "show-passive-items": true
      },

      "cpu": {
        "interval": 2,
        "format": "󰃴 {usage}%",
        "tooltip": true,
        "on-click": "''${term} -e htop"
      },

      "memory": {
        "interval": 2,
        "format": " {}%",
        "tooltip-format": "RAM: {used:0.1f}G / {total:0.1f}G\\nSwap: {swapUsed:0.1f}G / {swapTotal:0.1f}G",
        "on-click": "''${term} -e htop"
      },

      "temperature": {
        "thermal-zone": 1,
        "critical-threshold": 80,
        "interval": 2,
        "format": "{icon} {temperatureC}°C",
        "format-icons": ["", "", "", "", ""],
        "tooltip": true
      },

      "backlight": {
        "device": "intel_backlight",
        "format": "{icon} {percent}%",
        "format-icons": ["", "", ""],
        "on-scroll-up": "brightnessctl set 5%+",
        "on-scroll-down": "brightnessctl set 5%-",
        "tooltip": false
      },

      "battery": {
        "interval": 10,
        "states": {
          "warning": 30,
          "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-full": " {capacity}%",
        "format-icons": ["", "", "", "", "", "", "", "", "", "", ""],
        "tooltip-format": "{timeTo}\\nPower: {power}W"
      },

      "network": {
        "interval": 2,
        "format-wifi": " {signalStrength}%",
        "format-ethernet": " {ipaddr}",
        "format-linked": " {ifname} (No IP)",
        "format-disconnected": " Disconnected",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}\\nUp: {bandwidthUpBytes} Down: {bandwidthDownBytes}",
        "tooltip-format-wifi": "{essid} ({signalStrength}%)\\n{ipaddr}/{cidr}\\nUp: {bandwidthUpBytes} Down: {bandwidthDownBytes}",
        "on-click": "nm-connection-editor"
      },

      "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " Muted",
        "format-icons": {
          "headphone": "",
          "hands-free": "",
          "headset": "",
          "phone": "",
          "portable": "",
          "car": "",
          "default": ["", "", ""]
        },
        "scroll-step": 5,
        "on-click": "pavucontrol",
        "on-click-right": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "tooltip-format": "{desc}\\nVolume: {volume}%"
      }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 12px;
      font-weight: 500;
      border: none;
      border-radius: 0;
      min-height: 0;
    }

    window#waybar {
      background: transparent;
      color: #cdd6f4;
    }

    /* ========================================
       WORKSPACES
       ======================================== */
    #workspaces {
      background: rgba(30, 30, 46, 0.9);
      padding: 0 4px;
      margin: 0 8px 0 0;
      border-radius: 12px;
    }

    #workspaces button {
      padding: 0 10px;
      margin: 4px 2px;
      background: transparent;
      color: #a6adc8;
      border-radius: 8px;
      transition: all 0.2s ease-in-out;
    }

    #workspaces button.active {
      color: #1e1e2e;
      background: linear-gradient(45deg, #cba6f7, #f5c2e7);
      font-weight: 700;
    }

    #workspaces button.urgent {
      color: #1e1e2e;
      background: #f38ba8;
    }

    #workspaces button:hover {
      background: #45475a;
      color: #cdd6f4;
    }

    /* ========================================
       WINDOW TITLE
       ======================================== */
    #window {
      background: rgba(30, 30, 46, 0.9);
      padding: 4px 14px;
      margin: 0 8px 0 0;
      border-radius: 12px;
      color: #cdd6f4;
      font-weight: 600;
    }

    /* ========================================
       CLOCK
       ======================================== */
    #clock {
      background: rgba(30, 30, 46, 0.9);
      padding: 4px 16px;
      border-radius: 12px;
      color: #cba6f7;
      font-weight: 700;
    }

    /* ========================================
       MODULES (RIGHT SIDE)
       ======================================== */
    #tray,
    #idle_inhibitor,
    #pulseaudio,
    #network,
    #cpu,
    #memory,
    #temperature,
    #backlight,
    #battery {
      background: rgba(30, 30, 46, 0.9);
      padding: 4px 12px;
      margin: 0 0 0 8px;
      border-radius: 12px;
      color: #cdd6f4;
    }

    #tray {
      padding: 4px 8px;
    }

    #idle_inhibitor.activated {
      color: #f9e2af;
    }

    #cpu {
      color: #89b4fa;
    }

    #memory {
      color: #a6e3a1;
    }

    #temperature {
      color: #f9e2af;
    }

    #temperature.critical {
      color: #f38ba8;
      animation: blink 1s ease-in-out infinite;
    }

    #backlight {
      color: #fab387;
    }

    #battery {
      color: #a6e3a1;
    }

    #battery.warning {
      color: #f9e2af;
    }

    #battery.critical {
      color: #f38ba8;
      animation: blink 1s ease-in-out infinite;
    }

    #battery.charging {
      color: #a6e3a1;
    }

    #network {
      color: #89dceb;
    }

    #network.disconnected {
      color: #f38ba8;
    }

    #pulseaudio {
      color: #cba6f7;
    }

    #pulseaudio.muted {
      color: #6c7086;
    }

    @keyframes blink {
      50% {
        opacity: 0.5;
      }
    }

    /* ========================================
       TOOLTIPS
       ======================================== */
    tooltip {
      background: rgba(30, 30, 46, 0.95);
      border: 2px solid #cba6f7;
      border-radius: 12px;
      padding: 8px;
    }

    tooltip label {
      color: #cdd6f4;
    }
  '';

  # ============================================
  # Mako - Notification daemon
  # ============================================
  xdg.configFile."mako/config".text = ''
    # Appearance
    font=JetBrainsMono Nerd Font 11
    background-color=#1e1e2ef0
    text-color=#cdd6f4
    border-color=#cba6f7
    progress-color=over #45475a
    border-size=2
    border-radius=12
    padding=12
    margin=10
    
    # Behavior
    default-timeout=5000
    ignore-timeout=0
    max-visible=5
    layer=overlay
    anchor=top-right
    
    # Icons
    icons=1
    max-icon-size=48
    icon-path=/run/current-system/sw/share/icons/Papirus-Dark
    
    # Grouping
    group-by=app-name
    
    # Actions
    actions=1
    
    # Format
    format=<b>%s</b>\\n%b
    
    # Urgency levels
    [urgency=low]
    border-color=#94e2d5
    default-timeout=3000
    
    [urgency=normal]
    border-color=#cba6f7
    default-timeout=5000
    
    [urgency=critical]
    border-color=#f38ba8
    default-timeout=0
    ignore-timeout=1
    
    # App-specific rules
    [app-name="volume"]
    border-color=#cba6f7
    default-timeout=2000
    group-by=app-name
    
    [app-name="brightness"]
    border-color=#fab387
    default-timeout=2000
    group-by=app-name
    
    [app-name="battery"]
    border-color=#a6e3a1
    default-timeout=10000
  '';

  # ============================================
  # Fuzzel - Application launcher
  # ============================================
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=12
    dpi-aware=yes
    prompt=" ❯ "
    icon-theme=Papirus-Dark
    icons-enabled=yes
    fields=filename,name,generic
    fuzzy=yes
    show-actions=yes
    terminal=''${term}
    
    # Geometry
    width=50
    lines=15
    tabs=4
    horizontal-pad=20
    vertical-pad=12
    inner-pad=8
    
    # Appearance
    line-height=24
    letter-spacing=0
    
    [colors]
    background=#1e1e2ef0
    text=#cdd6f4ff
    match=#cba6f7ff
    selection=#313244ff
    selection-text=#cdd6f4ff
    selection-match=#f5c2e7ff
    border=#cba6f7ff
    
    [border]
    width=2
    radius=12
    
    [dmenu]
    exit-immediately-if-empty=yes
  '';

  # ============================================
  # Environment variables for Wayland
  # ============================================
  home.sessionVariables = {
    # Wayland support
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    
    # XDG
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
    
    # Qt theming
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
