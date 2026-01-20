{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> { };
in
{
  ############################################
  # Wi-Fi e Bluetooth
  ############################################
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Firmware específico para Broadcom BCM4312 LP-PHY
  environment.systemPackages = with pkgs; [
    linux-firmware
    bluez
    blueman
    b43-fwcutter
    wirelesstools
    pciutils
    usbutils
    unstable.rfkill
  ];

  # Kernel modules
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" "bcma" ];
  boot.kernelModules = [ "ssb" "b43" "bcma" ];

  # Evita drivers conflitantes
  boot.blacklistedKernelModules = [ "brcmsmac" "wl" ];

  ############################################
  # GRUB bootloader
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.devices = [ "/dev/sda" ];

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
