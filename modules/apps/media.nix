# modules/apps/media.nix
# Media and graphics tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.media.enable {
    home.packages = with pkgs; [
      gimp
      inkscape
      audacity
      handbrake
      mpv
      imagemagick
      transmission_4-gtk
    ];
  };
}
