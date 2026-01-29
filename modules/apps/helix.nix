# modules/apps/helix.nix
# Helix editor
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.helix.enable {
    home.packages = with pkgs; [
      helix
    ];
  };
}
