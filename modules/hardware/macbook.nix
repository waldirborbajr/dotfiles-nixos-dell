# modules/hardware/macbook.nix
{ config, pkgs, ... }:

{
  # Habilita firmware redistribuível
  hardware.enableRedistributableFirmware = true;

  # Blacklist módulos open-source que conflitam com o driver proprietário
  boot.blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
  ];

  # Carrega o módulo proprietário Broadcom (wl)
  boot.kernelModules = [ "wl" ];

  # Pacote do driver como extra module
  boot.extraModulePackages = with config.boot.kernelPackages; [
    linuxPackages.broadcom-sta
  ];

  # Pacotes úteis para debug/wireless
  environment.systemPackages = with pkgs; [
    iw
    wirelesstools  # inclui iwconfig, ifconfig e ferramentas wireless
    # rfkill removido, não existe no Nixpkgs 25.11
  ];
}
