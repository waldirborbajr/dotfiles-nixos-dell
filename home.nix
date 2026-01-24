# home.nix
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.11";
  home.username = "borba";
  home.homeDirectory = lib.mkForce "/home/borba";
}
