{ config, pkgs, ... }:

{
  ##########################################
  # Flatpak Support
  ##########################################

  services.flatpak.enable = true;

  ##########################################
  # Flatpak Remotes
  ##########################################

  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  ##########################################
  # XDG Integration (recommended)
  ##########################################

  xdg.portal.enable = true;

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  ##########################################
  # Fonts / Icons consistency
  ##########################################

  fonts.fontDir.enable = true;
}
