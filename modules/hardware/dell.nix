{ pkgs, ... }:
{
  hardware.enableRedistributableFirmware = true;

  networking.enableB43Firmware = true;

  boot.blacklistedKernelModules = [ "brcmsmac" "wl" ];

  environment.systemPackages = with pkgs; [
    b43-firmware-legacy
    b43-fwcutter
    wirelesstools
    rfkill
  ];


}
