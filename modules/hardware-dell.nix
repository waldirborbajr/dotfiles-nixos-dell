{ config, pkgs, ... }:

{
  ############################################
  # Wi-Fi e Bluetooth (Dell Inspiron)
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  # Pacotes de firmware necessários
  environment.systemPackages = with pkgs; [
    firmware.b43         # Broadcom Wi-Fi
    firmware.b43-open    # Versão open do firmware
    firmware.intel-ucode # Microcode Intel
    firmware.broadcom-wl # Broadcom STA (opcional, mais recente)
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

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
  boot.extraModulePackages = [ ];
}
