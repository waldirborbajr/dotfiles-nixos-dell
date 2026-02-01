# modules/apps/media/video.nix
# Video editing and conversion tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.media.video.enable {
    home.packages = with pkgs; [
      handbrake # Video transcoder
    ];
  };
}
