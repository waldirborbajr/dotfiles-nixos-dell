# modules/apps/productivity/workflow.nix
# Development workflow automation tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.workflow.enable {
    home.packages = with pkgs; [
      entr # Run commands when files change
    ];

    # Direnv integration
    programs.direnv = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
      nix-direnv.enable = true;
    };
  };
}
