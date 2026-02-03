# modules/apps/productivity.nix
# Modern CLI productivity tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.productivity.enable {
    home.packages = with pkgs; [
      # File operations
      eza
      fd
      dust
      ncdu
      tree

      # Navigation
      zoxide

      # Shell history
      atuin

      # Documentation
      tldr

      # Text processing
      sd
      jq
      fx

      # HTTP client
      httpie

      # Development workflow
      direnv
      entr

      # System monitoring
      procs
      btop

      # Git UI
      lazygit
    ];

    # Zoxide integration (if zsh is enabled)
    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable ''
      # Zoxide integration
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init --cmd cd zsh)"
      fi
    '';

    # Atuin integration (if zsh is enabled)
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        search_mode = "fuzzy";
        style = "compact";
      };
    };

    # Direnv integration
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # Shell aliases for productivity tools
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      # Eza (already in zsh.nix, but ensure consistency)
      ls = "eza";
      ll = "eza -lg --icons --group-directories-first";
      la = "eza -lag --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";

      # Modern replacements
      cat = "bat";
      find = "fd";

      # Git UI
      lg = "lazygit";

      # Disk usage
      du = "dust";
      df = "dust";

      # Process monitoring
      ps = "procs";
      top = "btop";
      htop = "btop";
    };
  };
}
