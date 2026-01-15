{ config, pkgs, userConfig, ... }:

{
  home.username = "borba";
  home.homeDirectory = "/home/borba";
  home.stateVersion = "25.11";

  imports = [
    ../programs/git/default.nix
    ../programs/zsh/defult.nix
  ];

  home.packages = with pkgs; [
    # programas só para o usuário borba
    # ... outros que quiserem ficar fora do system
  ];

  programs = {
    # zsh extra config, aliases, etc.
    zsh = {
      enable = true;
      # shellAliases = { ... };
      # initExtra = '' ... '';
    };

    # Outros programas do usuário: git, neovim, etc.
  };

  # dotfiles via home-manager (opcional)
  # home.file.".config/nvim".source = ./dotfiles/nvim;
}