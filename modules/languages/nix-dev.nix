# modules/languages/nix-dev.nix
# Nix development tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.languages.nix-dev.enable {
    # ========================================
    # Nix development packages
    # ========================================
    home.packages = with pkgs; [
      nixpkgs-fmt # Formatter (official)
      alejandra # Alternative formatter (opinionated)
      nil # Nix LSP
      nixd # Alternative Nix LSP
      nix-tree # Visualize derivations
      nix-diff # Diff derivations
      nix-update # Update package versions
      nix-init # Generate nix expressions
      statix # Linter
      deadnix # Dead code detection
    ];

    # ========================================
    # Shell aliases
    # ========================================
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      nxfmt = "nixpkgs-fmt";
      nxfmta = "alejandra";
      nxtree = "nix-tree";
      nxdiff = "nix-diff";
      nxupd = "nix-update";
      nxlint = "statix check";
      nxfix = "statix fix";
      nxdead = "deadnix";
      nxbuild = "nix build";
      nxdev = "nix develop";
      nxshell = "nix-shell";
      nxflake = "nix flake";
    };

    # ========================================
    # Environment variables
    # ========================================
    home.sessionVariables = {
      NIX_PATH = "nixpkgs=${pkgs.path}";
    };
  };
}
