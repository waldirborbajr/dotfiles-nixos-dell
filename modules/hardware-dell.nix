{ config, pkgs, lib, ... }:

{
  ############################################
  # Wi-Fi / Networking
  ############################################
  networking.networkmanager.enable = true

  # Enable redistributable firmware (needed for Dell Wi-Fi/Bluetooth)
  hardware.enableRedistributableFirmware = true

  # Load Broadcom B43 firmware for Wi-Fi
  boot.extraModulePackages = with pkgs; [
    b43-firmware
    b43-openfwwf
  ];

  ############################################
  # Bluetooth
  ############################################
  hardware.bluetooth.enable = true
  hardware.bluetooth.powerOnBoot = true
  services.blueman.enable = true

  ############################################
  # Audio (PipeWire)
  ############################################
  services.pulseaudio.enable = false
  security.rtkit.enable = true
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################################
  # Keyboard — Dell Inspiron (pt_BR)
  ############################################
  # Teclado gráfico (X11 / Wayland via XKB)
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Teclado de console (TTY / initrd)
  console.keyMap = "br-abnt2";

  ############################################
  # Bootloader (Legacy BIOS - Dell)
  ############################################
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  ############################################
  # Kernel modules (virtualization, optional)
  ############################################
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "ums_realtek" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = lib.mkDefault boot.extraModulePackages;
}
