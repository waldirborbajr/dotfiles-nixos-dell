# modules/apps/productivity/text-processing.nix
# Text and data processing tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.text-processing.enable {
    home.packages = with pkgs; [
      sd             # Modern sed replacement
      jq             # JSON processor
      yq-go          # YAML processor
      fx             # JSON viewer
      tldr           # Simplified man pages
    ];
  };
}
