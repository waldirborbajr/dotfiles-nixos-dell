# modules/flatpak/enable.nix
# ---

# modules/flatpak/enable.nix
{ config, pkgs, lib, ... }:

{
  services.flatpak.enable = true;

  environment.systemPackages =
    lib.optionals config.services.flatpak.enable [
      pkgs.flatpak
    ];

  xdg.portal.enable = true;

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];
}



#{ config, pkgs, lib, ... }:

#{
  ##########################################
  # Flatpak
  ##########################################

#  services.flatpak.enable = true;

#  environment.systemPackages =
#    lib.optionals config.services.flatpak.enable [
#      pkgs.flatpak
#    ];

  ##########################################
  # XDG Portal (needed for Flatpak apps)
  ##########################################

 # xdg.portal.enable = true;

#  xdg.portal.extraPortals = with pkgs; [
#    xdg-desktop-portal-gtk
#  ];
#}


# # modules/flatpak/enable.nix
# # ---
# { config, pkgs, ... }:

# {
#   ##########################################
#   # Flatpak
#   ##########################################

#   services.flatpak.enable = true;

#   ##########################################
#   # XDG Portal (needed for Flatpak apps)
#   ##########################################

#   xdg.portal.enable = true;

#   xdg.portal.extraPortals = with pkgs; [
#     xdg-desktop-portal-gtk
#   ];
# }

