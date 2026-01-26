# modules/desktops/i3.nix
{ pkgs, ... }:

{
  ############################################
  # X11 + i3 Window Manager
  ############################################
  services.xserver.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    i3
    i3status
    dmenu
    feh
    picom
  ];
}
