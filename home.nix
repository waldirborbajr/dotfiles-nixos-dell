# home.nix
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.11";
  home.username = "borba";
  home.homeDirectory = lib.mkForce "/home/borba";

  # Importa os módulos que você quer ativar (padrão modular mantido)
  imports = [
    ./modules/apps/zsh.nix
    ./modules/apps/fzf.nix
    ./modules/apps/git.nix
    ./modules/apps/gh.nix
    ./modules/apps/go.nix
    ./modules/apps/rust.nix
    ./modules/apps/lua.nix
  ];
}
