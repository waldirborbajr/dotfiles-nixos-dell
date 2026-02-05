# modules/desktops/niri/audio.nix
# Audio control utilities for Niri
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
lib.mkIf isMacbook {
  home.packages = with pkgs; [
    pavucontrol  # PulseAudio Volume Control GUI
    pamixer      # PulseAudio command-line mixer
    playerctl    # Media player controller
    helvum       # GTK patchbay for PipeWire
  ];
}
