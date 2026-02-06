# modules/hardware/macbook.nix
{ config, pkgs, ... }:

{
  ############################################
  # Intel GPU Hardware Acceleration (VA-API)
  ############################################
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Modern Intel (iHD)
      intel-vaapi-driver # Older Intel (i965) - MacBook 2011 uses this
      libvdpau-va-gl
    ];
  };

  ############################################
  # Broadcom / Wireless
  ############################################
  hardware.enableRedistributableFirmware = true;

  # Blacklist drivers that conflict with proprietary Broadcom
  boot.blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
  ];

  # Proprietary Broadcom driver
  boot.kernelModules = [ "wl" ];

  # Driver package for the active kernel
  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  ############################################
  # Bluetooth
  ############################################
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  ############################################
  # Useful packages for wireless debug and configuration
  ############################################
  #environment.systemPackages = with pkgs; [
  #iw
  #wirelesstools
  #  util-linux
  #  linuxPackages.broadcom_sta    
  #];
}
