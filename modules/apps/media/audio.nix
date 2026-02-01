# modules/apps/media/audio.nix
# Audio editing and playback tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.media.audio.enable {
    home.packages = with pkgs; [
      audacity # Audio editor
      mpv # Media player
    ];
  };
}
