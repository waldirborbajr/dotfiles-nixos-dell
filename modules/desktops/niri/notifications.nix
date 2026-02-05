# modules/desktops/niri/notifications.nix
# Notification daemon for Niri
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
lib.mkIf isMacbook {
  home.packages = with pkgs; [
    libnotify      # Notification library (provides notify-send)
  ];
}
