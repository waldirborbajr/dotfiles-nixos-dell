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

  ############################################
  # Keyboard (Dell)
  ############################################
  console.keyMap = "br-abnt2";

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };
}
