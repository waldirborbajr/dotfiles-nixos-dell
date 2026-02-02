# modules/apps/termius.nix
# Termius SSH client with cloud sync
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.termius.enable {
    home.packages = with pkgs; [
      termius # Modern SSH client with cloud sync
    ];

    # Shell alias
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      term = "termius";
    };
  };
}
