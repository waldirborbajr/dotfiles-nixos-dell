# modules/apps/clipboard.nix
# Clipboard and screenshot tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.clipboard.enable {
    home.packages = with pkgs; [
      xclip          # X11 clipboard
      wl-clipboard   # Wayland clipboard
      clipster       # Clipboard manager
      
      # Wayland screenshot tools (flameshot replacement)
      grim           # Screenshot utility for Wayland
      slurp          # Screen area selector for Wayland
      swappy         # Screenshot editor (like flameshot)
      grimblast      # Convenient wrapper for grim+slurp
    ];
  };
}
