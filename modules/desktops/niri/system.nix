# modules/desktops/niri/system.nix
# System-level Niri configuration for GDM session selector
{ config, pkgs, lib, ... }:

{
  # Enable Niri at system level for GDM session
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Additional packages for Niri
  environment.systemPackages = with pkgs; [
    xwayland-satellite # For X11 apps on Wayland
  ];

  # XDG Portal configuration for Niri
  # Reuses GNOME portals for compatibility since both are enabled
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
  ];

  # Wayland environment for Niri session
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
