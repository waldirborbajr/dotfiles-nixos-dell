# modules/apps/latex.nix
# LaTeX typesetting system and tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.latex.enable {
    home.packages = with pkgs; [
      # LaTeX distribution (full scheme with all packages)
      texlive.combined.scheme-full

      # LaTeX workflow tools
      texlab # LaTeX Language Server
      latexrun # LaTeX build wrapper
      tectonic # Modern LaTeX compiler (alternative)

      # Typst - Modern typesetting system
      typst # Typst compiler
      typst-lsp # Typst Language Server

      # PDF viewers
      zathura # Lightweight PDF viewer
      evince # GNOME PDF viewer

      # Bibliography management
      biber # BibTeX replacement

      # Diagram tools
      graphviz # For dot2tex

      # Spell checking
      aspell
      aspellDicts.en
      aspellDicts.pt_BR
    ];

    # LaTeX-related shell aliases
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      # Quick compilation
      ltx = "latexmk -pdf -interaction=nonstopmode";
      ltxc = "latexmk -c"; # Clean auxiliary files
      ltxC = "latexmk -C"; # Clean all generated files

      # Modern compiler
      tec = "tectonic";

      # Typst aliases
      typ = "typst compile";
      typw = "typst watch"; # Watch and recompile

      # PDF viewer
      pdf = "zathura";
    };

    # LaTeX environment variables
    home.sessionVariables = {
      TEXMFHOME = "${config.home.homeDirectory}/.texmf";
    };
  };
}
