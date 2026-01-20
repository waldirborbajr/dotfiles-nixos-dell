{ config, pkgs, ... }:

{
  ############################################
  # Wi-Fi e Bluetooth (Dell Inspiron)
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  # Firmware Broadcom / Intel / Bluetooth
  environment.systemPackages = with pkgs; [
    linuxFirmware.b43        # Broadcom Wi-Fi
    linuxFirmware.b43-open   # Versão open
    linuxFirmware.broadcom   # Broadcom STA
    linuxFirmware.intel      # Intel microcode
    linuxFirmware.broadcom-wl
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  ############################################
  # Audio (PipeWire)
  ############################################
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################################
  # Keyboard — Dell Inspiron (pt_BR)
  ############################################
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
  console.keyMap = "br-abnt2";

  ############################################
  # Bootloader (GRUB)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;

  ############################################
  # Kernel Modules
  ############################################
  boot.initrd.availableKernelModules = [
    "ehci_pci" "ahci" "ums_realtek" "usb_storage" "sd_mod" "sr_mod"
    "b43"       # Broadcom Wi-Fi
    "btusb"     # Bluetooth USB
  ];
  boot.kernelModules = [ "kvm-intel" ];
}
