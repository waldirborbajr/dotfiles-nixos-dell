{ config, pkgs, ... }:

{
  ############################################
  # Enable NetworkManager (Wi-Fi / Ethernet)
  ############################################
  networking.networkmanager.enable = true;

  ############################################
  # Enable redistributable firmware (Dell Wi-Fi / BT)
  ############################################
  hardware.enableRedistributableFirmware = true;

  ############################################
  # Bluetooth
  ############################################
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
    "ehci_pci"
    "ahci"
    "ums_realtek"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "b43"       # Broadcom Wi-Fi
    "btusb"     # Bluetooth USB
  ];

  boot.kernelModules = [ "kvm-intel" ];

  ############################################
  # System packages for firmware
  ############################################
  environment.systemPackages = with pkgs; [
    linux-firmware      # Inclui Broadcom b43, btusb e outros firmwares
  ];
}
