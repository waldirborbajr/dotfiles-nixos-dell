{ config, pkgs, lib, ... }:

{
  ############################################
  # Imports
  ############################################
  imports = [
    # Hardware profile - Dell (BIOS / Legacy)
    ./hardware-configuration-dell.nix
    ./modules/hardware-dell.nix
    # Kernel / performance tuning
    ./modules/kernel-tuning.nix
    # Desktop environment - GNOME
    ./modules/desktop-gnome.nix
    # Base system packages and programs
    ./modules/fonts.nix
    ./modules/system-programs.nix
    ./modules/system-packages.nix
    # Containers
    ./modules/containers/docker.nix
    ./modules/containers/k3s.nix
    # Maintenance / Garbage collection
    ./modules/maintenance.nix
    ./modules/maintenance-hm.nix
    # User configuration
    ./modules/user-borba.nix
    # Nix (unstable overlay)
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ############################################
  # Remote access (SSH)
  ############################################
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # Wi-Fi e Bluetooth (Broadcom BCM4312)
  ############################################
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Firmware específico para BCM4312 LP-PHY (b43)
  boot.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];

  # Sistema instala firmware Broadcom
  environment.systemPackages = with pkgs; [
    linux-firmware
    bluez
    blueman
    pciutils
    usbutils
    wireless_tools    # pacote correto no nixpkgs
    rfkill
    b43-fwcutter      # Broadcom firmware utility
  ];

  ############################################
  # Bootloader (GRUB)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = false;
  # Use o device do seu disco, normalmente /dev/sda
  boot.loader.grub.devices = [ "/dev/sda" ];

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
