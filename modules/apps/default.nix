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
    ./helix.nix
    ./neovim.nix
    ./starship.nix
    ./ides.nix
    ./knowledge.nix
    ./media.nix
    ./productivity.nix
    ./remote.nix
    ./clipboard.nix
    ./multiplexers.nix
    ./latex.nix
    ./fun-tools.nix
    
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
