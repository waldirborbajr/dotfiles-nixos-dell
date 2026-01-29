# modules/apps/browsers.nix
# Web browsers (Firefox, Brave)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.browsers.enable {
    home.packages = with pkgs; [
      firefox
      brave
    ];

    home.sessionVariables = {
      BROWSER = "firefox";
    };
  };
}
