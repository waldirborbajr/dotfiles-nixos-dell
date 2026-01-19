{ pkgs, ... }:

{
  programs = {
    zsh.enable = true;
    firefox.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
