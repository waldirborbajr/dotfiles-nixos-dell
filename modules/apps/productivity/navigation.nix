# modules/apps/productivity/navigation.nix
# Smart directory navigation tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.navigation.enable {
    home.packages = with pkgs; [
      zoxide         # Smart directory jumper
    ];

    # Zoxide integration
    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable ''
      # Zoxide integration
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init --cmd cd zsh)"
      fi
    '';
  };
}
