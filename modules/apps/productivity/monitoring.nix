# modules/apps/productivity/monitoring.nix
# System monitoring and process management tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.monitoring.enable {
    home.packages = with pkgs; [
      procs # Modern ps replacement
      btop # Resource monitor
    ];

    # Shell aliases
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      ps = "procs";
      top = "btop";
      htop = "btop";
    };
  };
}
