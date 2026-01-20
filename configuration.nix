{ config, pkgs, ... }:

{
  ############################################
  # Wi-Fi e Bluetooth (Broadcom BCM4312)
  ############################################
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Firmware Broadcom específico
  environment.systemPackages = with pkgs; [
    linux-firmware       # Inclui firmware Broadcom, Intel e outros
    bluez
    blueman
    b43-fwcutter
    pciutils
    usbutils
  ];

  # Força carregamento dos módulos corretos
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.kernelModules = [ "ssb" "b43" ];

  # Evita conflitos com outros drivers Broadcom
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];
}
