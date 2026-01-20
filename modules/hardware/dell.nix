{ config, pkgs, lib, ... }:

{
  networking.enableB43Firmware = true;

  environment.systemPackages = with pkgs; [
    b43FirmwareCutter
    iw
  ];
}
