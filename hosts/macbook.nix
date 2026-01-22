{ config, pkgs, lib, ... }:

{
  ############################################
  # Hardware & Performance
  ############################################
  imports = [
    ../modules/hardware/macbook.nix
    ../modules/performance/macbook.nix
    ../hardware-configuration-macbook.nix
  ];

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

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "";

  ############################################
  # Firmware & Broadcom wireless fix
  ############################################
  hardware.enableRedistributableFirmware = true;
  networking.enableB43Firmware = true;

  boot.blacklistedKernelModules = [
    "brcmsmac"
    "wl"
  ];

  environment.systemPackages = with pkgs; [
    firmware.b43          # Broadcom open firmware
    firmware.b43legacy    # Broadcom legacy firmware
    linuxPackages.broadcom-sta  # Proprietary STA driver
    wirelesstools
    rfkill
  ];
}
