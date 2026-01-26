# modules/apps/terminals.nix
# Consolidado: Alacritty + Kitty
{ config, pkgs, lib, ... }:

{
  # ========================================
  # Alacritty (Home Manager)
  # ========================================
  home.packages = with pkgs; [
    alacritty
    kitty
    nerd-fonts.jetbrains-mono
  ];

  xdg.configFile."alacritty/alacritty.toml".text = ''
    [env]
    TERM = "xterm-256color"

    [window]
    padding = { x = 8, y = 8 }
    decorations = "None"
    opacity = 1.0
    blur = false
    dynamic_title = true
    resize_increments = true
    startup_mode = "Fullscreen"

    [debug]
    render_timer = false
    persistent_logging = false
    log_level = "Off"

    [terminal.shell]
    program = "${pkgs.zsh}/bin/zsh"
    args = ["-l"]

    [font]
    size = 13.0
    builtin_box_drawing = true
    normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
    bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
    italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
    offset = { x = 0, y = 1 }
    glyph_offset = { x = 0, y = 0 }

    [cursor]
    unfocused_hollow = true
    style = "Beam"
    vi_mode_style = "Block"

    [scrolling]
    history = 5000
    multiplier = 3

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
  '';
}
