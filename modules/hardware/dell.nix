{
  config,
  pkgs,
  lib,
  ...
}:

{
  networking.enableB43Firmware = true;

  # Dell ACPI modules break Wi-Fi/Bluetooth on older models
  boot.blacklistedKernelModules = [
    "dell_laptop"
  ];

  environment.systemPackages = with pkgs; [
    b43FirmwareCutter
    iw
  ];
}
