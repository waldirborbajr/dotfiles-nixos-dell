# modules/virtualization/virtualbox.nix
# VirtualBox virtualization
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.virtualbox.enable {
    home.packages = with pkgs; [
      virtualbox
    ];
  };
}
