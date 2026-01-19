{ config, pkgs, ... }:

{
  ############################################
  # Wi-Fi
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  ############################################
  # Bluetooth
  ############################################
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

  # Teclado gráfico (X11 / Wayland via XKB)
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Teclado de console (TTY / initrd)
  console.keyMap = "br-abnt2";
    
}
