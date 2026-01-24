# modules/apps/alacritty.nix
{ config, pkgs, lib, ... }:

{
  ############################################
  # Packages (Nix-managed)
  ############################################
  environment.systemPackages = with pkgs; [
    alacritty
    nerd-fonts.jetbrains-mono
  ];

  ############################################
  # Alacritty config (Nix-managed)
  # Canonical: /etc/xdg/alacritty/alacritty.toml
  ############################################
  environment.etc."xdg/alacritty/alacritty.toml".text = ''
    # =========================
    # Ambiente
    # =========================
    [env]
    TERM = "xterm-256color"

    # =========================
    # Janela
    # =========================
    [window]
    padding = { x = 8, y = 8 }
    decorations = "None"
    opacity = 1.0
    blur = false
    dynamic_title = true
    resize_increments = true
    startup_mode = "Fullscreen"

    # =========================
    # Performance / Debug
    # =========================
    [debug]
    render_timer = false
    persistent_logging = false
    log_level = "Off"

    # =========================
    # Shell (NO tmux autostart)
    # =========================
    [terminal.shell]
    program = "${pkgs.zsh}/bin/zsh"
    args = ["-l"]

    # =========================
    # Fonte
    # =========================
    [font]
    size = 13.0
    builtin_box_drawing = true

    normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
    bold   = { family = "JetBrainsMono Nerd Font", style = "Bold" }
    italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }

    offset = { x = 0, y = 1 }
    glyph_offset = { x = 0, y = 0 }

    # =========================
    # Cursor
    # =========================
    [cursor]
    unfocused_hollow = true
    style = "Beam"
    vi_mode_style = "Block"

    # =========================
    # Scrolling
    # =========================
    [scrolling]
    history = 5000
    multiplier = 3

    # =========================
    # Cores — Catppuccin Mocha
    # =========================
    [colors.primary]
    background = "#1e1e2e"
    foreground = "#cdd6f4"

    [colors.normal]
    black   = "#45475a"
    red     = "#f38ba8"
    green   = "#a6e3a1"
    yellow  = "#f9e2af"
    blue    = "#89b4fa"
    magenta = "#f5c2e7"
    cyan    = "#94e2d5"
    white   = "#bac2de"

    [colors.bright]
    black   = "#585b70"
    red     = "#f38ba8"
    green   = "#a6e3a1"
    yellow  = "#f9e2af"
    blue    = "#89b4fa"
    magenta = "#f5c2e7"
    cyan    = "#94e2d5"
    white   = "#a6adc8"

    # =========================
    # Teclado
    # =========================
    [keyboard]
    bindings = [
      # Clipboard
      { key = "C", mods = "Control|Shift", action = "Copy" },
      { key = "V", mods = "Control|Shift", action = "Paste" },

      # Fonte
      { key = "Key0",   mods = "Control", action = "ResetFontSize" },
      { key = "Equals", mods = "Control", action = "IncreaseFontSize" },
      { key = "Minus",  mods = "Control", action = "DecreaseFontSize" },

      # Fullscreen
      { key = "F11", action = "ToggleFullscreen" },

      # Clear + scrollback
      { key = "L", mods = "Control", chars = "\u000c" },

      # Scroll manual
      { key = "K", mods = "Control|Shift", action = "ScrollPageUp" },
      { key = "J", mods = "Control|Shift", action = "ScrollPageDown" },
    ]
  '';

  ############################################
  # Symlink into ~/.config (no Home-Manager)
  # - Only creates link if the target does not exist
  ############################################
  systemd.user.services."xdg-config-links-alacritty" = {
    description = "Symlink Alacritty XDG config from /etc/xdg to ~/.config";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      mkdir -p "$HOME/.config/alacritty"

      # Alacritty
      [ -e "$HOME/.config/alacritty/alacritty.toml" ] || ln -s /etc/xdg/alacritty/alacritty.toml "$HOME/.config/alacritty/alacritty.toml"
    '';
  };
}