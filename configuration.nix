# configuration.nix - Dell Inspiron 1564 (Legacy BIOS)
{ config, pkgs, lib, ... }:

{
  ############################################
  # Imports
  ############################################
  imports = [
    ./hardware-configuration-dell.nix
    ./modules/kernel-tuning.nix
    ./modules/desktop-gnome.nix
    ./modules/fonts.nix
    ./modules/system-programs.nix
    ./modules/system-packages.nix
    ./modules/containers/docker.nix
    ./modules/containers/k3s.nix
    ./modules/maintenance.nix
    ./modules/user-borba.nix
    ./modules/nix-unstable.nix
  ];

  ############################################
  # Host
  ############################################
  networking.hostName = "nixos";

  ############################################
  # Locale / Time
  ############################################
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  ############################################
  # Nix configuration
  ############################################
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  ############################################
  # Remote access (SSH)
  ############################################
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # Wi-Fi e Bluetooth (Broadcom BCM4312 LP-PHY)
  ############################################
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Carrega os módulos corretos
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.kernelModules = [ "ssb" "b43" ];

  # Evita conflitos com outros drivers Broadcom
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];

  # Pacotes de firmware e utilitários
  environment.systemPackages = with pkgs; [
    linux-firmware
    bluez
    blueman
    wireless-tools
    pciutils
    usbutils
  ];

  ############################################
  # Bootloader (GRUB)
  ############################################
  boot.loader.grub = {
    enable = true;
    version = 2;
    useOSProber = false;
    devices = [ "/dev/sda" ];  # disco de boot principal
  };

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
