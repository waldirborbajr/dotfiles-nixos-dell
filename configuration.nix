{ config, pkgs, ... }:

{
  imports = [

    ##########################################
    # Host profile (choose ONE)
    ##########################################
    ./profiles/dell.nix
    # ./profiles/macbook.nix

    ##########################################
    # Hardware
    ##########################################
    ./hardware-configuration-dell.nix
    ./modules/hardware/dell.nix

    ##########################################
    # Core system
    ##########################################
    ./modules/base.nix
    ./modules/networking.nix
    ./modules/audio.nix
    ./modules/fonts.nix

    ##########################################
    # Desktop
    ##########################################
    ./modules/desktops/gnome.nix
    ./modules/autologin.nix

    ##########################################
    # Containers / Virtualization
    ##########################################
    ./modules/containers/docker.nix
    ./modules/containers/k3s.nix
    ./modules/virtualization/libvirt.nix

    ##########################################
    # Users / Packages / Nix
    ##########################################
    ./modules/users/borba.nix
    ./modules/system-packages.nix
    ./modules/nixpkgs.nix

  ];

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
