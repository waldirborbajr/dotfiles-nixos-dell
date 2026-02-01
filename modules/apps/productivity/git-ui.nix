# modules/apps/productivity/git-ui.nix
# Terminal UI for Git operations
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.git-ui.enable {
    home.packages = with pkgs; [
      lazygit # Terminal UI for git
    ];

    # Shell alias
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      lg = "lazygit";
    };
  };
}
