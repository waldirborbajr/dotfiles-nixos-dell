# modules/apps/media/image.nix
# Image editing and manipulation tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.media.image.enable {
    home.packages = with pkgs; [
      gimp # GNU Image Manipulation Program
      inkscape # Vector graphics editor
      imagemagick # CLI image manipulation
    ];
  };
}
