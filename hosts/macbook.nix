# hosts/macbook.nix
# Config completa do host MacBook
{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.11";

  ############################################
  # Hardware & Performance
  ############################################
  imports = [
    ../hardware/macbook.nix
    ../hardware/performance/macbook.nix
    ../hardware/macbook-hw-config.nix

    # Desktop apenas no MacBook
    ../modules/desktops/gnome.nix
    ../modules/autologin.nix

    # Apps system-level
    ../modules/apps/kitty.nix
    ../modules/apps/tmux.nix
  ];

  ############################################
  # Host identity
  ############################################
  networking.hostName = "macbook-nixos";

  ############################################
  # GNOME services
  ############################################
  services.gnome.gnome-keyring.enable = true;

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
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  ############################################
  # Broadcom Wi-Fi (insecure package)
  ############################################
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.66"
  ];

  environment.systemPackages = with pkgs; [
    iw
    wirelesstools
    util-linux
    config.boot.kernelPackages.broadcom_sta
  ];
}
