# hosts/macbook.nix
# ---
{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.11";

  ############################################
  # Hardware & Performance
  ############################################
  imports = [
    ../modules/nixpkgs.nix
    ../modules/hardware/macbook.nix
    ../modules/performance/macbook.nix
    ../hardware-configuration-macbook.nix
  ];

  ############################################
  # Hardware & Performance
  ############################################
  #imports = [
  #  ../modules/nixpkgs.nix              # Módulo Nixpkgs primeiro para allowUnfree
  #  ../modules/hardware/macbook.nix
  #  ../modules/performance/macbook.nix
  #  ../hardware-configuration-macbook.nix
  #];

  ############################################
  # Host identity
  ############################################
  networking.hostName = "macbook-nixos";

  ############################################
  # Bootloader (EFI)
  ############################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ############################################
  # Keyboard layout
  ############################################
  console.keyMap = "us";

  ############################################
  # X11 layout
  ############################################
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  ############################################
  # Permitir pacote Broadcom STA inseguro
  ############################################
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.66"
  ];

  ############################################
  # Pacotes extras para Wi-Fi e debug
  ############################################
  environment.systemPackages = with pkgs; [
    iw
    wirelesstools
    util-linux              # garante rfkill
    config.boot.kernelPackages.broadcom_sta
  ];
}
