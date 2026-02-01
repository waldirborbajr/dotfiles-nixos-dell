# modules/apps/productivity/http-clients.nix
# Modern HTTP clients and API testing tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.http-clients.enable {
    home.packages = with pkgs; [
      httpie # User-friendly HTTP client
    ];
  };
}
