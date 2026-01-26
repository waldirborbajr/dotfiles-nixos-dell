# modules/apps/terminals.nix
# Alacritty terminal with Catppuccin theme
{ config, pkgs, lib, ... }:

{
  # ========================================
  # Alacritty (Home Manager)
  # ========================================
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Enable Catppuccin theme for Alacritty
  programs.alacritty = {
    enable = true;
    catppuccin.enable = true;  # Uses global theme config
    
    settings = {
      env.TERM = "xterm-256color";
      
      window = {
        padding = { x = 8; y = 8; };
        decorations = "None";
        opacity = 1.0;
        blur = false;
        dynamic_title = true;
        resize_increments = true;
        startup_mode = "Fullscreen";
      };

      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };

      font = {
        size = 13.0;
        builtin_box_drawing = true;
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        bold = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
        italic = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
        offset = { x = 0; y = 1; };
        glyph_offset = { x = 0; y = 0; };
      };

      cursor = {
        unfocused_hollow = true;
        style = "Beam";
        vi_mode_style = "Block";
      };

      scrolling = {
        history = 5000;
        multiplier = 3;
      };

      debug = {
        render_timer = false;
        persistent_logging = false;
        log_level = "Off";
      };
    };
  };
}

