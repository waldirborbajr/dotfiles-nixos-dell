{ ... }:

{
  ############################################
  # Host identity
  ############################################
  networking.hostName = "dell-nixos";

  ############################################
  # Bootloader (Legacy BIOS)
  ############################################
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };
}
