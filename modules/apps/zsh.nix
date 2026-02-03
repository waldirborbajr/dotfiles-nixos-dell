# modules/apps/zsh.nix
# ZSH configuration with fzf + bat integration
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.zsh.enable {
    programs.zsh = {
      enable = true;

      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        share = true;
        expireDuplicatesFirst = true;
        extended = true;
      };

      shellAliases = {
        c = "clear";
        q = "exit";
        ll = "eza -lg --icons --group-directories-first";
        la = "eza -lag --icons --group-directories-first";
        gs = "git status --short";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gu = "git pull";
        gd = "git diff";
        gds = "git diff --staged";
        runfree = ''"$@" >/dev/null 2>&1 & disown'';
        cat = "bat";
        fzf-preview = "fzf --preview 'bat --color=always {}'";
        fzf-history = "history | fzf";
      };

      initContent = ''
        # Vi mode
        bindkey -v

        # Completion
        autoload -Uz compinit && compinit
        
        # Simple prompt
        PROMPT='%F{cyan}%~%f %F{green}❯%f '
      '';
    };

    programs.bat.enable = true;
    programs.fzf.enable = true;
  };
}
