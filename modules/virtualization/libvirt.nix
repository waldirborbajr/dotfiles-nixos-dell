{ ... }:
{
  virtualisation.libvirtd = {
    enable = true;

    qemu.swtpm.enable = true;

    allowedBridges = [
      "virbr0"
      "br0"
    ];
  };

  security.polkit.enable = true;
}
