{ config, pkgs, ... }:

{
  imports = [

    ##########################################
    # Host profile
    # Choose ONLY ONE
    ##########################################

    # Dell Inspiron 1564 (Legacy BIOS)
    ./profiles/dell.nix

    # MacBook Pro 13" 2011 (EFI)
    # Uncomment this when deploying on the MacBook
    # ./profiles/macbook.nix


    ##########################################
    # Shared system modules (host-agnostic)
    ##########################################
    ./modules/kernel-tuning.nix
    ./modules/fonts.nix
    ./modules/system-packages.nix

    ./modules/desktop-gnome.nix

    ./modules/containers/docker.nix
    ./modules/containers/k3s.nix

    ./modules/maintenance.nix
    ./modules/maintenance-hm.nix

    ./modules/user-borba.nix
    ./modules/nix-unstable.nix

    ./modules/autologin.nix

  ];

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
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
