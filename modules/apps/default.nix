# modules/apps/default.nix
# Home-manager level applications with individual enable options
{ config, lib, ... }:

{
  imports = [
    # Core apps
    ./shell.nix
    ./terminals.nix
    ./fastfetch.nix
    ./dev-tools.nix
    ./ripgrep.nix
    ./yazi.nix
    ./tmux.nix
    ./chirp.nix
    
    # New apps (migrated from system)
    ./browsers.nix
    ./communication.nix
    ./editors.nix
    ./ides.nix
    ./knowledge.nix
    ./media.nix
    ./productivity.nix
    ./remote.nix
    ./clipboard.nix
    ./multiplexers.nix
  ];

  options.apps = {
    shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable zsh shell with fzf and bat";
      };
    };

    terminals = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable terminal emulator (alacritty)";
      };
    };

    fastfetch = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable fastfetch system info tool";
      };
    };

    dev-tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable development tools (git, gh)";
      };
    };

    ripgrep = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable ripgrep with DevOps optimizations";
      };
    };

    yazi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable yazi file manager";
      };
    };

    tmux = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable tmux with Catppuccin theme";
      };
    };

    chirp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Chirp ham radio programming tool";
      };
    };

    browsers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable web browsers (Firefox, Brave)";
      };
    };

    communication = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable communication tools (Discord)";
      };
    };

    editors = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable text editors (Helix, Neovim)";
      };
    };
ides = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable IDEs (VSCode)";
      };
    };

    
    knowledge = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable knowledge management tools (Obsidian)";
      };
    };

    media = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable media and graphics tools";
      };
    };

    productivity = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable modern CLI productivity tools";
      };
    };

    remote = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable remote access tools (AnyDesk)";
      };
    };

    clipboard = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable clipboard and screenshot tools";
      };
    };

    multiplexers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable terminal multiplexers (tmuxifier, zellij)";
      };
    };
  };
}
