{ config, pkgs, ... }:

{
  ############################################
  # X11 + Display Manager
  ############################################
  services.xserver.enable = true;

  services.displayManager.lightdm.enable = true;
  services.displayManager.lightdm.greeters.slick.enable = true;

  ############################################
  # Cinnamon Desktop Environment
  ############################################
  services.xserver.desktopManager.cinnamon.enable = true;

  ############################################
  # Network
  ############################################
  networking.networkmanager.enable = true;

  ############################################
  # Essential desktop utilities
  ############################################
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    pavucontrol
    xdg-utils
    gnome.gnome-keyring
  ];

  ############################################
  # Polkit (required)
  ############################################
  security.polkit.enable = true;
}
