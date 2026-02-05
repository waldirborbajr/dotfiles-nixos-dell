# modules/hardware/macbook.nix
{ config, pkgs, ... }:

{
  ############################################
  # Intel GPU Hardware Acceleration (VA-API)
  ############################################
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Modern Intel (iHD)
      intel-vaapi-driver # Older Intel (i965) - MacBook 2011 uses this
      libvdpau-va-gl
    ];
  };

  ############################################
  # Broadcom / Wireless
  ############################################
  hardware.enableRedistributableFirmware = true;

  # Blacklist drivers que conflitam com Broadcom proprietário
  boot.blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
  ];

  # Driver proprietário Broadcom
  boot.kernelModules = [ "wl" ];

  # Pacote do driver para o kernel ativo
  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  ############################################
  # Bluetooth
  ############################################
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  ############################################
  # Pacotes úteis para debug e configuração wireless
  ############################################
  #environment.systemPackages = with pkgs; [
  #iw
  #wirelesstools
  #  util-linux
  #  linuxPackages.broadcom_sta    
  #];
}
