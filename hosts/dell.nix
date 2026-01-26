# hosts/dell.nix
# Config completa do host Dell
{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.11";

  ############################################
  # Hardware & Performance
  ############################################
  imports = [
    ../hardware/dell.nix
    ../hardware/performance/dell.nix
    ../hardware/dell-hw-config.nix
    ../modules/desktops/i3.nix
  ];

  ############################################
  # Hard-disable virtualization (slow machine)
  # All virtualization services disabled by default
  # in modules/virtualization/, no overrides needed
  ############################################

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
  # Keyboard (Dell)
  ############################################
  console.keyMap = "br-abnt2";

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };
}
