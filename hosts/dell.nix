# hosts/dell.nix
# ---
#     nixos-config/hosts/dell.nix

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
  # Hardware
  ############################################
  #imports = [
  #  ../modules/hardware/dell.nix
  #  ../modules/performance/dell.nix
  #  ../hardware-configuration-dell.nix
  #];

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
