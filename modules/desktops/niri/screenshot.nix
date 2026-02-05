# modules/desktops/niri/screenshot.nix
# Screenshot utilities for Niri
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
lib.mkIf isMacbook {
  home.packages = with pkgs; [
    grim           # Screenshot utility for Wayland
    slurp          # Region selector for Wayland
    swappy         # Screenshot editor
  ];
}
