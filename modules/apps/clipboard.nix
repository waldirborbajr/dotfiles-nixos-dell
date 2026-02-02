# modules/apps/clipboard.nix
# Clipboard and screenshot tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.clipboard.enable {
    home.packages = with pkgs; [
      xclip          # X11 clipboard
      wl-clipboard   # Wayland clipboard
      clipster       # Clipboard manager
      
      # Screenshot tools for GNOME/Wayland
      gnome-screenshot  # Native GNOME screenshot tool
      ksnip            # Cross-platform screenshot tool with annotation (flameshot alternative)
      
      # Wayland screenshot tools (for niri and other compositors)
      grim           # Screenshot utility for Wayland
      slurp          # Screen area selector for Wayland
      swappy         # Screenshot editor
      grimblast      # Convenient wrapper for grim+slurp
    ];
  };
}
