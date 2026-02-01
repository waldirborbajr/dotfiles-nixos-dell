# modules/apps/yazi.nix
# Modern terminal file manager with preview support
# KISS: Keep It Simple, Stupid
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.yazi.enable {
    # Install yazi with dependencies
    home.packages = with pkgs; [
      yazi
      # Dependencies for full functionality
      ffmpegthumbnailer # Video thumbnails
      unar # Archive preview
      jq # JSON preview
      poppler-utils # PDF preview
      fd # File searching
      ripgrep # Content searching
      fzf # Fuzzy finding
      zoxide # Smart directory jumping
      imagemagick # Image operations
    ];

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;

      # Use 'y' as shell wrapper for directory changing
      shellWrapperName = "y";

      # Basic settings
      settings = {
        mgr = {
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
    };

    # Simple aliases
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      y = "yazi";
      yy = "yazi .";
    };
  };
}
