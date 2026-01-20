{ config, pkgs, ... }:

{
  ############################################
  # Wi-Fi e Bluetooth
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  ############################################
  # Kernel Modules
  ############################################
  boot.initrd.kernelModules = [ "b43" "btusb" ];

  ############################################
  # Pacotes de firmware e utilitários
  ############################################
  environment.systemPackages = with pkgs; [
    linux-firmware       # Firmware Broadcom, Intel e outros
    bluez                # CLI Bluetooth
    blueman              # GUI para BT
  ];

  ############################################
  # Bootloader (GRUB)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];  # disco de boot principal
  boot.loader.grub.useOSProber = false;       # evita warnings de outros OS
}
