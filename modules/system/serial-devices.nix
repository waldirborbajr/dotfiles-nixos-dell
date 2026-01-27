# modules/system/serial-devices.nix
# Configuration for serial device access (e.g., for Chirp and amateur radio programming)
{ config, pkgs, lib, ... }:

{
  # Exclude brltty which can conflict with serial ports used by Chirp
  # brltty is a screen reader for the blind that can interfere with USB serial devices
  services.brltty.enable = lib.mkForce false;
  
  # Ensure chirp's udev rules are installed for proper USB device access
  services.udev.packages = [ pkgs.chirp ];

  # Note: User needs to be in 'dialout' group for serial port access
  # This is already configured in modules/users/borba.nix
}
