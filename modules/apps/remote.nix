# modules/apps/remote.nix
# Remote access tools (Anydesk, etc.)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.remote.enable {
    home.packages = with pkgs; [
      anydesk
    ];
  };
}
