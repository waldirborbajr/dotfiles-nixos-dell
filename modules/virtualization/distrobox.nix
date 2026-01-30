# modules/virtualization/distrobox.nix
# Distrobox container tool
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.distrobox.enable {
    home.packages = with pkgs; [
      distrobox
    ];
  };
}
