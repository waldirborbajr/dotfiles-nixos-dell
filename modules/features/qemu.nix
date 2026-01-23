# modules/features/qemu.nix
# ---
{ config, lib, pkgs, qemuEnabled ? false, ... }:

let
  enable = qemuEnabled;
in
{
  # Default OFF (services)
  virtualisation.libvirtd.enable = lib.mkDefault false;

  # Keep packages optional: you can keep them always installed elsewhere,
  # but this module guarantees services are only ON when QEMU=1.
  config = lib.mkIf enable {
    virtualisation.libvirtd.enable = true;

    # qemu + virt-manager are packages; keep them if you want.
    # If you already install these in system-packages.nix, no need to repeat.
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      qemu
      spice
      spice-gtk
      spice-protocol
      virtio-win
    ];

    # Useful groups for non-root usage
    users.users.borba.extraGroups = [ "libvirtd" "kvm" ];
  };
}
