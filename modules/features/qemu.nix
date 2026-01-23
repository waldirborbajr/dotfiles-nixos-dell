# modules/features/qemu.nix
# ---
{ config, lib, pkgs, qemuEnabled ? false, ... }:

let
  enable = qemuEnabled;
in
{
  config = lib.mkMerge [
    # Default OFF (serviço não sobe)
    {
      virtualisation.libvirtd.enable = lib.mkDefault false;
    }

    # QEMU=1 -> ON
    (lib.mkIf enable {
      virtualisation.libvirtd = {
        enable = true;

        # Opcional: útil para TPM em VMs (Windows 11 etc.)
        qemu.swtpm.enable = true;

        allowedBridges = [
          "virbr0"
          "br0"
        ];
      };

      security.polkit.enable = true;

      # Tooling (opcional aqui; se já estiver no system-packages, pode remover daqui)
      environment.systemPackages = with pkgs; [
        virt-manager
        virt-viewer
        qemu
        spice
        spice-gtk
        spice-protocol
        virtio-win
      ];

      users.users.borba.extraGroups = lib.mkAfter [ "libvirtd" "kvm" ];
    })
  ];
}
