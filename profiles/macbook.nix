{ ... }:

{
  ############################################
  # Host identity
  ############################################
  networking.hostName = "macbook-nixos";

  ############################################
  # Bootloader (EFI)
  ############################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ############################################
  # Keyboard (MacBook)
  ############################################
  console.keyMap = "us";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
