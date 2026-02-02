# hosts/dell.nix
# Config completa do host Dell
{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.11";

  ############################################
  # Hardware & Performance & Profile
  ############################################
  imports = [
    ../hardware/dell.nix
    ../hardware/performance/dell.nix
    ../hardware/dell-hw-config.nix
    ../profiles/desktop.nix
    ../modules/desktops/i3.nix
  ];

  ############################################
  # Hard-disable virtualization (slow machine)
  ############################################
  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.podman.enable = lib.mkForce false;

  ############################################
  # Enable Tailscale VPN
  ############################################
  features.tailscale.enable = true;

  ############################################
  # Host identity
  ############################################
  networking.hostName = "dell-nixos";

  ############################################
  # Bootloader (Legacy BIOS)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];

  ############################################
  # Keyboard (Dell)
  ############################################
  console.keyMap = "br-abnt2";

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };
}
