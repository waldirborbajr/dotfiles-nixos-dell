# modules/apps/clipboard.nix
# Clipboard and screenshot tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.clipboard.enable {
    home.packages = with pkgs; [
      xclip
      wl-clipboard
      clipster
      flameshot
    ];
  };
}
