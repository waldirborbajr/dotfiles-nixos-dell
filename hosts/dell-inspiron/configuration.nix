# hosts/dell-inspiron/configuration.nix
{ ... }:

{
  imports = [
    ../../hardware-configuration-dell.nix

    ../../modules/nixpkgs.nix
    ../../modules/base.nix
    ../../modules/networking.nix
    ../../modules/audio.nix
    ../../modules/fonts.nix
    ../../modules/kernel-tuning.nix
    ../../modules/maintenance.nix

    ../../modules/users/borba.nix
    ../../modules/system-packages.nix

    ../../modules/desktops/gnome.nix
    ../../modules/containers/docker.nix
    ../../modules/virtualization/libvirt.nix
    ../../modules/hardware/dell.nix
  ];

  networking.hostName = "dell-nixos";
  system.stateVersion = "25.11";
}
