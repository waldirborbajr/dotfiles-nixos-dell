# modules/apps/ides.nix
# Integrated Development Environments
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.ides.enable {
    home.packages = with pkgs; [
      vscode
    ];
  };
}
