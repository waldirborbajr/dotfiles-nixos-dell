# modules/virtualization/libvirt.nix
# QEMU/KVM virtualization via Libvirt
# Use this for creating VMs with virt-manager
# Pode ser desabilitado via: virtualisation.libvirtd.enable = false;

{ config, pkgs, lib, ... }:

{
  virtualisation.libvirtd = {
    enable = lib.mkDefault false; # Disabled by default - enable only when needed
    qemu.swtpm.enable = true; # TPM support for Windows 11 VMs
    allowedBridges = [ "virbr0" "br0" ];
  };

  security.polkit.enable = lib.mkIf config.virtualisation.libvirtd.enable true;

  environment.systemPackages = lib.mkIf config.virtualisation.libvirtd.enable [
    pkgs.virt-manager
    pkgs.virt-viewer
    pkgs.qemu
    pkgs.spice
    pkgs.spice-gtk
    pkgs.spice-protocol
    pkgs.virtio-win
  ];

  users.users.borba.extraGroups = lib.mkIf config.virtualisation.libvirtd.enable [
    "libvirtd"
    "kvm"
  ];
}
