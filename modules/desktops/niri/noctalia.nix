# modules/desktops/niri/noctalia.nix
# Noctalia - Wayland desktop shell and launcher
{ config, pkgs, lib, hostname, inputs, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
{
  imports = lib.mkIf isMacbook [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf isMacbook {
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
    };
  };
}
