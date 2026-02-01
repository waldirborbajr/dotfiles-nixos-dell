# modules/apps/media/torrents.nix
# BitTorrent clients
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.media.torrents.enable {
    home.packages = with pkgs; [
      transmission_4-gtk # BitTorrent client
    ];
  };
}
