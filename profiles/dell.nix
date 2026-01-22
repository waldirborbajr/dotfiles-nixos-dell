{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.11";

  ############################################
  # Hardware
  ############################################
  imports = [
    ../modules/hardware/dell.nix
    ../modules/performance/dell.nix
    ../hardware-configuration-dell.nix
  ];

  ############################################
  # Host identity
  ############################################
  networking.hostName = "dell-nixos";

  ############################################
  # Bootloader (Legacy BIOS)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];

  ############################################
  # X11 + i3 (somente Dell)
  ############################################
  services.xserver.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
  };

  ############################################
  # Keyboard
  ############################################
  console.keyMap = "br-abnt2";

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  ############################################
  # Pacotes específicos do Dell
  ############################################
  environment.systemPackages = with pkgs; [
    i3
    i3status
    dmenu
    feh
    picom
  ];
}
