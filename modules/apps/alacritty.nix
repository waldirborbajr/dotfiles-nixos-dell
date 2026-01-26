# modules/apps/alacritty.nix
{ config, pkgs, lib, ... }:

{
  # Pacotes Nix-managed
  home.packages = with pkgs; [
    alacritty
    nerd-fonts.jetbrains-mono  # JetBrainsMono Nerd Font
  ];

  # Config declarativa (alacritty.toml em ~/.config/alacritty/)
  xdg.configFile."alacritty/alacritty.toml".text = ''
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
    bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
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

  
  '';

  # Opcional: força sobrescrita na primeira ativação (se já tiver arquivo antigo)
  # Remova ou comente após o primeiro rebuild bem-sucedido
  # xdg.configFile."alacritty/alacritty.toml".force = true;
}
