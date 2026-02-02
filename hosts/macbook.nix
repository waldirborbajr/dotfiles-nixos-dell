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
    ../profiles/developer.nix

    # Desktops - Multiple sessions available at GDM
    ../modules/desktops/gnome.nix
    ../modules/desktops/niri/system.nix # Niri as alternative session
    ../modules/autologin.nix
  ];

  ############################################
  # Enable specialized serial devices support
  ############################################
  system-config.serialDevices.enable = true;

  ############################################
  # Enable Tailscale VPN
  ############################################
  features.tailscale.enable = true;

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
    layout = "us,us";
    variant = ",intl"; # US puro (default), US-intl (com dead keys)
  };

  ############################################
  # Broadcom Wi-Fi (insecure package)
  ############################################
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.66"
  ];

  # Wi-Fi driver packages (system-level, hardware requirement)
  # Other packages moved to home-manager
  environment.systemPackages = with pkgs; [
    iw
    wirelesstools
    util-linux
    config.boot.kernelPackages.broadcom_sta
  ];
}
