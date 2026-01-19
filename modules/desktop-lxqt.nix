{ config, pkgs, ... }:

{
  ############################################
  # X11 + Display Manager
  ############################################
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "lxqt";

  ############################################
  # LXQt Desktop Environment
  ############################################
  services.xserver.desktopManager.lxqt.enable = true;

  ############################################
  # Basic desktop utilities (minimal)
  ############################################
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    pavucontrol
    lxqt.lxqt-policykit
    xdg-utils
  ];

  ############################################
  # Network
  ############################################
  networking.networkmanager.enable = true;
}
