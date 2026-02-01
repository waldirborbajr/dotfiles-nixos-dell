# modules/apps/productivity/shell-history.nix
# Enhanced shell history management
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.shell-history.enable {
    home.packages = with pkgs; [
      atuin # Magical shell history
    ];

    # Atuin integration
    programs.atuin = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        search_mode = "fuzzy";
        style = "compact";
      };
    };
  };
}
