# configuration.nix
{ config, pkgs, lib, ... }:

{
  ############################################
  # Core system modules
  ############################################
  ./core.nix

  ############################################
  # Host-specific configurations
  ############################################
  imports = [
    ./hosts/macbook.nix
    # ./hosts/dell.nix

  ];

  ############################################
  # NixOS version compatibility
  ############################################
  system.stateVersion = "25.11";
}
