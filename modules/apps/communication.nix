# modules/apps/communication.nix
# Communication tools (Discord, etc.)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.communication.enable {
    home.packages = with pkgs; [
      discord
    ];
  };
}
