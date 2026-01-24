# home.nix
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.11";
  home.username = "borba";
  home.homeDirectory = lib.mkForce "/home/borba";

  # Importa os módulos que você quer ativar (padrão modular mantido)
  imports = [
    ./modules/apps/zsh.nix
    # Futuro: ./modules/apps/fzf.nix (se criar)
    # ./modules/apps/uv.nix
    # ./modules/apps/poetry.nix
    # etc.
  ];
}
