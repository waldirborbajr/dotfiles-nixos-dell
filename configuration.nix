{ config, pkgs, ... }:

{
  ############################################
  # Imports
  ############################################
  imports = [
    ##########################################
    # Hardware profile - Dell (BIOS / Legacy)
    ##########################################
    ./hardware-configuration-dell.nix
    ./modules/hardware-dell.nix

    ##########################################
    # Hardware profile - MacBook (EFI)
    # Enable ONLY when running on MacBook
    ##########################################
    # ./modules/hardware-macbook.nix
    # ./modules/hardware-macbook-efi.nix

    ##########################################
    # Radio / Serial devices (CHIRP)
    ##########################################
    ./modules/hardware-radio-chirp.nix

    ##########################################
    # Kernel / performance tuning
    ##########################################
    ./modules/kernel-tuning.nix

    ##########################################
    # Desktop environment (choose ONE)
    ##########################################
    ./modules/desktop-gnome.nix
    # ./modules/desktop-cosmic.nix
    # ./modules/desktop-hyprland.nix

    ##########################################
    # Base system
    ##########################################
    ./modules/fonts.nix
    ./modules/system-programs.nix
    ./modules/system-packages.nix

    ##########################################
    # Containers / Orchestration
    # Docker + K3s enabled by default
    ##########################################
    ./modules/containers/docker.nix
    ./modules/containers/k3s.nix
    # ./modules/containers/podman.nix

    ##########################################
    # Optional virtualization tuning
    ##########################################
    # ./modules/virtualisation-bridge.nix
    # ./modules/virt-wayland-tuning.nix

    ##########################################
    # Maintenance / Garbage collection
    ##########################################
    ./modules/maintenance.nix
    ./modules/maintenance-hm.nix

    ##########################################
    # Users
    ##########################################
    ./modules/user-borba.nix

    ##########################################
    # Nix (unstable overlay)
    ##########################################
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
    LC_ADDRESS        = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT    = "pt_BR.UTF-8";
    LC_MONETARY       = "pt_BR.UTF-8";
    LC_NAME           = "pt_BR.UTF-8";
    LC_NUMERIC        = "pt_BR.UTF-8";
    LC_PAPER          = "pt_BR.UTF-8";
    LC_TELEPHONE      = "pt_BR.UTF-8";
    LC_TIME           = "pt_BR.UTF-8";
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
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
