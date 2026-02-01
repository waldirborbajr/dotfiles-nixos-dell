# modules/apps/productivity/git-ui.nix
# Terminal UI for Git operations
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.git-ui.enable {
    home.packages = with pkgs; [
      lazygit # Terminal UI for git
      lazyjj # Terminal UI for jujutsu
    ];

    # Shell aliases
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      lg = "lazygit";
      lj = "lazyjj";
    };
  };
}
