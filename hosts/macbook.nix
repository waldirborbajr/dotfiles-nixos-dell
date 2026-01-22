{ config, pkgs, lib, ... }:

{
  ############################################
  # Hardware
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
  # Keyboard (MacBook)
  ############################################
  console.keyMap = "us";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
