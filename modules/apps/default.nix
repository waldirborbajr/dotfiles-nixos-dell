# modules/apps/default.nix
# Home-manager level applications with individual enable options
{ config, lib, ... }:

{
  imports = [
    # Core apps
    ./shell.nix
    ./alacritty.nix
    ./wezterm.nix
    ./fastfetch.nix
    ./dev-tools.nix
    ./commitizen.nix
    ./ripgrep.nix
    ./yazi.nix
    ./tmux.nix
    ./chirp.nix

    # New apps (migrated from system)
    ./browsers.nix
    ./communication.nix
    ./helix.nix
    ./neovim.nix
    ./starship.nix
    ./ides.nix
    ./knowledge.nix
    ./remote.nix
    ./ssh-tools.nix
    ./termius.nix
    ./clipboard.nix
    ./zellij.nix
    ./latex.nix
    ./fun-tools.nix

    # Modular apps (Dendritic Pattern)
    ./media # Aggregator with submodules
    ./productivity # Aggregator with submodules

    # Virtualization tools (Home Manager level)
    ../virtualization/virtualbox.nix
    ../virtualization/distrobox.nix
  ];

  options.apps = {
    shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable zsh shell with fzf and bat";
      };
    };

    alacritty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Alacritty terminal emulator";
      };
    };

    wezterm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable WezTerm terminal emulator (backup/reserve option)";
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

    commitizen = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Commitizen for standardized git commits";
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

    helix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Helix editor";
      };
    };
    neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Neovim editor";
      };
    };
    starship = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Starship prompt";
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

    # Media tools - now with granular options
    # Options defined in ./media/default.nix
    # Use: apps.media.enable = true; (all)
    # Or:  apps.media.image.enable = true; (specific)

    # Productivity tools - now with granular options
    # Options defined in ./productivity/default.nix
    # Use: apps.productivity.enable = true; (all)
    # Or:  apps.productivity.file-tools.enable = true; (specific)

    remote = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable remote access tools (AnyDesk)";
      };
    };

    ssh-tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable SSH utilities and enhanced remote terminal tools (mosh, sshfs, etc.)";
      };
    };

    termius = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Termius SSH client with cloud sync";
      };
    };

    clipboard = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable clipboard and screenshot tools";
      };
    };

    multiplexers = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "DEPRECATED: Use zellij.enable instead. This option remains for backwards compatibility.";
      internal = true;
    };

    zellij = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Zellij terminal multiplexer (tmux alternative)";
      };
    };

    latex = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable LaTeX typesetting system and tools";
      };
    };

    # Virtualization tools
    virtualbox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable VirtualBox virtualization";
      };
    };

    distrobox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Distrobox container tool";
      };
    };

    # Fun CLI tools
    cbonsai = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable cbonsai bonsai tree generator";
      };
    };

    cmatrix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable cmatrix Matrix-style screen";
      };
    };

    pipes = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable pipes animated pipes screen";
      };
    };

    tty-clock = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable tty-clock terminal clock";
      };
    };
  };
}
