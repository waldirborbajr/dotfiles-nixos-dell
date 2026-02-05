# modules/desktops/niri/noctalia.nix
# Noctalia - Wayland desktop shell and launcher
{ config, pkgs, lib, hostname, inputs, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
lib.mkIf isMacbook {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
  };
}
