# modules/apps/neovim.nix
# Neovim editor
# NOTE: Neovim configured via dotfiles (stow), no plugins managed here
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.neovim.enable {
    home.packages = with pkgs; [
      neovim
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
    };
  };
}
