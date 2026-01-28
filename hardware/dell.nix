# modules/hardware/dell.nix
# ---
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================
  # Broadcom WiFi Configuration (SECURITY WARNING!)
  # ============================================
  # The broadcom-sta driver has known security vulnerabilities:
  # - CVE-2019-9501: heap buffer overflow (remote code execution)
  # - CVE-2019-9502: heap buffer overflow (remote code execution)
  # - Driver is unmaintained and incompatible with kernel security mitigations
  #
  # RECOMMENDATIONS (in order of preference):
  # 1. Replace WiFi card with modern Intel WiFi (best option)
  # 2. Use USB WiFi adapter with better driver support
  # 3. Use wired Ethernet connection
  # 4. Only if absolutely necessary, keep broadcom-sta (current config)
  #
  # To disable WiFi completely and remove this risk:
  # Comment out: networking.enableB43Firmware = true;
  # ============================================
  
  networking.enableB43Firmware = true;

  # Allow insecure broadcom-sta package
  # Required for b43 firmware to work on Broadcom WiFi cards
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.66"
  ];

  # Dell ACPI modules break Wi-Fi/Bluetooth on older models
  boot.blacklistedKernelModules = [
    "dell_laptop"
  ];

  environment.systemPackages = with pkgs; [
    b43FirmwareCutter
    #iw
  ];
}
