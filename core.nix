# core.nix
{ ... }:

{
  imports = [

    ##########################################
    # Core system
    ##########################################
    ./modules/nixpkgs.nix    
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
    # Users / Dev
    ##########################################
    ./modules/users/borba.nix
    ./modules/system-packages.nix
    ./modules/python/default.nix
    ./modules/nodejs/default.nix

    ##########################################
    # Flatpak
    ##########################################
    ./modules/flatpak/enable.nix
    ./modules/flatpak/packages.nix

    ##########################################
    # Access
    ##########################################
    ./modules/ssh.nix
  ];
}
