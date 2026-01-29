# modules/apps/editors.nix
# Text editors (Helix, Neovim)
# NOTE: Neovim configured via dotfiles (stow), no plugins managed here
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.editors.enable {
    home.packages = with pkgs; [
      helix
      neovim
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
    };
  };
}
