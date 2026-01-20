# hosts/macbook-2011/configuration.nix
{ ... }:

{
  imports = [
    ../../hardware-configuration-macbook.nix

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
    ../../modules/hardware/macbook.nix
    ../../modules/hardware/macbook-efi.nix
  ];

  networking.hostName = "macbook-nixos";
  system.stateVersion = "25.11";
}
