{ config, pkgs, ... }:

{
  ############################################
  # Imports
  ############################################
  imports = [
    # Hardware
    ./hardware-configuration-dell.nix
    ./modules/hardware-dell.nix
    ./modules/hardware-radio-chirp.nix

    # Kernel / performance
    ./modules/kernel-tuning.nix

    # Desktop (choose ONE)
    ./modules/desktop-gnome.nix
    # ./modules/desktop-cosmic.nix
    # ./modules/desktop-hyprland.nix

    # Base system
    ./modules/fonts.nix
    ./modules/system-programs.nix
    ./modules/system-packages.nix

    # Containers / Virtualization
    ./modules/k3s.nix
    # ./modules/virtualisation-bridge.nix
    # ./modules/virt-wayland-tuning.nix

    # Maintenance
    ./modules/maintenance.nix
    ./modules/maintenance-hm.nix

    # Users
    ./modules/user-borba.nix
  ];

  ############################################
  # Bootloader
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  ############################################
  # Host
  ############################################
  networking.hostName = "nixos";

  ############################################
  # Locale / Time
  ############################################
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  ############################################
  # Nix
  ############################################
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  ############################################
  # SSH
  ############################################
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # State version
  ############################################
  system.stateVersion = "25.11";
}
