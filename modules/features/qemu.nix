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

      # Tooling (only installed when QEMU is enabled)
      environment.systemPackages = with pkgs; [
        virt-manager
        virt-viewer
        qemu
        qemu_kvm
        spice
        spice-gtk
        spice-protocol
        virtio-win    # Windows drivers (~500MB)
        OVMF          # UEFI firmware for VMs
      ];

      users.users.borba.extraGroups = lib.mkAfter [ "libvirtd" "kvm" ];
    })
  ];
}
