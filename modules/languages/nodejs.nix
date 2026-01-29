# modules/languages/nodejs.nix
# Node.js system-level installation
# Aliases and environment variables in nodejs-home.nix (home-manager)
{ config, pkgs, lib, ... }:

{
  # ========================================
  # Node.js (system-level, always active)
  # ========================================
  environment.systemPackages = with pkgs; [
    nodejs_20
    nodePackages.pnpm
  ];
}
