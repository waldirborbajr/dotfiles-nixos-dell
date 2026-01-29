# modules/apps/knowledge.nix
# Knowledge management tools (Obsidian, etc.)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.knowledge.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
