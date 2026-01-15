# Exemplo: hosts/desktop/default.nix  ← teclado US comum
{ config, pkgs, ... }:

{
  networking.hostName = "nix-macbook";

  boot.loader.grub.device = "/dev/sda";

  imports = [
    ./hardware-configuration.nix
  ];

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "intl";  # se quiser dead keys (ç, á, etc.)

  console.keyMap = "us";

  # Talvez mais potência, RGB, etc.
}
