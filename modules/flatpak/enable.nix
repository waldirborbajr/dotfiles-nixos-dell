{ pkgs, ... }:

{
  ##########################################
  # Flatpak
  ##########################################

  services.flatpak.enable = true;

  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  ##########################################
  # XDG Portal (required)
  ##########################################

  xdg.portal.enable = true;

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];
}
