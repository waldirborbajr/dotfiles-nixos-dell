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
  services.xserver = {
    enable = true;
    layout = {
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };
}
