# modules/xdg-portal.nix
# Basic XDG Portal setup - Desktop modules extend this
{ config, pkgs, lib, ... }:

{
  xdg.portal = {
    enable = lib.mkDefault true;
    xdgOpenUsePortal = lib.mkDefault true;
    
    # Minimal fallback portal for non-desktop environments
    extraPortals = lib.mkDefault (with pkgs; [
      xdg-desktop-portal-gtk
    ]);
  };
}
