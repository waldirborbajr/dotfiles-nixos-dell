{ config, pkgs, ... }:

{
  networking.hostName = "nix-dell";

  boot.loader.grub.device = "/dev/sda";

  imports = [
    ./hardware-configuration.nix
  ];

  # Teclado X11 / Wayland (GNOME, etc.)
  services.xserver.xkb.layout = "br";

  # Console / TTY (Ctrl+Alt+F3, etc.)
  console.keyMap = "br-abnt2";

  # Outras coisas específicas do laptop aqui
  # powerManagement.enable = true;
  # services.tlp.enable = true;
}