{ config, pkgs, ... }:

{
  # imports = [
  #   ./hardware-configuration.nix

  #   # Core system
  #   ./modules/system-programs.nix
  #   ./modules/system-packages.nix

  #   ./modules/maintenance.nix
  #   ./modules/maintenance-hm.nix

  #   # User
  #   ./modules/user-borba.nix

  #   # Desktop (ESCOLHA UM)
  #   ./modules/desktop-gnome.nix
  #   # ./modules/desktop-cosmic.nix

  #   # Kernel / Boot tuning
  #   ./modules/kernel-tuning.nix
  # ];

  imports = [
    ./hardware-configuration-dell.nix

    # Hardware profile
    ./modules/hardware-dell.nix

    # MacBook profile
    # ./modules/hardware-macbook.nix
    # ./modules/hardware-macbook-efi.nix    

    # Kernel / performance
    ./modules/kernel-tuning.nix

    # Desktop (choose ONE)
    ./modules/desktop-gnome.nix
    # ./modules/desktop-cosmic.nix

    # Base system
    ./modules/fonts.nix
    ./modules/system-programs.nix
    ./modules/system-packages.nix

    # Virtualization
    # ./modules/virtualisation-bridge.nix
    # ./modules/virt-wayland-tuning.nix

    # Maintenance
    ./modules/maintenance.nix
    ./modules/maintenance-hm.nix

    # Users
    ./modules/user-borba.nix

    ./modules/nix-unstable.nix
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
  # Docker (system service)
  ############################################
  virtualisation.docker.enable = true;

  ############################################
  # Nix
  ############################################
  nixpkgs.config.allowUnfree = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  ############################################
  # SSH
  ############################################
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.11";
}
