# modules/languages/python.nix
# Python system-level installation
# Aliases and environment variables in python-home.nix (home-manager)
{ config, pkgs, lib, ... }:

let
  pythonEnv = "uv"; # uv | poetry | none
in
{
  # ========================================
  # Python base (system-level, always active)
  # ========================================
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
  ] ++ lib.optionals (pythonEnv == "uv") [
    uv
  ] ++ lib.optionals (pythonEnv == "poetry") [
    poetry
  ];
}
