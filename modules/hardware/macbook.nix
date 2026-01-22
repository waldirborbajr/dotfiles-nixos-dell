# modules/hardware/macbook.nix
{ config, pkgs, ... }:

{
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
  # Pacotes úteis para debug e configuração wireless
  ############################################
  #environment.systemPackages = with pkgs; [
    #iw
    #wirelesstools
  #  util-linux
  #  linuxPackages.broadcom_sta    
  #];
}
