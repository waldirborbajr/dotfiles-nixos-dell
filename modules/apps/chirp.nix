# modules/apps/chirp.nix
# Chirp - Tool for programming amateur radios
{ config, pkgs, lib, ... }:

{
  # Install Chirp
  home.packages = with pkgs; [ 
    chirp
  ];

  # Note: The following system-level configurations are needed:
  # 1. User must be in dialout group (already configured in modules/users/borba.nix)
  # 2. Exclude brltty if present (it can conflict with serial ports)
  # 3. Udev rules are automatically handled by NixOS when chirp is installed at system level
}
