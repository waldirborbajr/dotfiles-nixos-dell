# modules/apps/multiplexers.nix
# Terminal multiplexers (tmuxifier, zellij)
# NOTE: tmux configured in tmux.nix
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.multiplexers.enable {
    home.packages = with pkgs; [
      tmuxifier
      zellij
    ];
  };
}
