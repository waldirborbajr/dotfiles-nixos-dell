{ config, pkgs, ... }:

{
  ############################################
  # Rede e Bluetooth
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
    linuxFirmware        # Inclui firmware para Wi-Fi Broadcom e outros
    bluez                # Bluetooth CLI utilities
    blueman              # GUI para BT
  ];
}
