# profiles/dell.nix
# ---
{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.11";

  ############################################
  # Hardware (Dell-only)
  ############################################
  imports = [
    ../modules/hardware/dell.nix
    ../modules/performance/dell.nix
    ../hardware-configuration-dell.nix
  ];

  # Docker OFF no Dell (máquina lenta)
  virtualisation.docker.enable = lib.mkForce false;

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
  # X11 + i3 (Dell-only)
  ############################################
  services.xserver.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
  };

  ############################################
  # Keyboard (Dell)
  ############################################
  console.keyMap = "br-abnt2";

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  ############################################
  # Dell-only desktop packages
  ############################################
  environment.systemPackages = with pkgs; [
    i3
    i3status
    dmenu
    feh
    picom
  ];
}
