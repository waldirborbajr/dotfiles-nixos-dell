# modules/apps/shell.nix
# Consolidado: zsh + fzf + bat
{ config, pkgs, lib, ... }:

{
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
      rg = "rg --hidden --smart-case --glob='!.git/' --no-search-zip --trim";
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
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward

      # Completion
      autoload -Uz compinit && compinit -C
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no

      # bat como pager/manpager
      if command -v bat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
        export PAGER=bat
      fi

      # zoxide
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init --cmd cd zsh)"
      fi

      # Prompt customizado com git status melhorado
      git_seg() {
        local s branch dirty staged untracked ahead behind color

        branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || true)"
        [ -n "$branch" ] || return 0

        local st="$(git status --porcelain=v1 2>/dev/null || true)"
        dirty=""
        staged=""
        untracked=""
        if echo "$st" | grep -qE '^[ MARC?DU][MD] '; then staged="+"; fi
        if echo "$st" | grep -qE '^[MDARC?DU][ MD] '; then dirty="*"; fi
        if echo "$st" | grep -qE '^\?\? '; then untracked="?"; fi

        ahead=""
        behind=""
        if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
          counts="$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || true)"
          counts=$(echo "$counts" | tr '\t' ' ')
          left=$(echo "$counts" | awk '{print $1}')
          right=$(echo "$counts" | awk '{print $2}')
          [ "''${left:-0}" -gt 0 ] && ahead="⇡''${left}"
          [ "''${right:-0}" -gt 0 ] && behind="⇣''${right}"
        fi

        if [ -n "$ahead" ]; then
          color="%F{green}"
        elif [ -n "$behind" ]; then
          color="%F{red}"
        elif [ -n "$dirty$staged$untracked" ]; then
          color="%F{yellow}"
        else
          color="%F{magenta}"
        fi

        s="''${color}''${branch}''${staged}''${dirty}''${untracked}''${ahead}''${behind}%f"
        echo " $s"
      }

      precmd() {
        local code=$?
        local sym
        if [ $code -eq 0 ]; then
          sym="%F{green}❯%f"
        else
          sym="%F{red}❯%f"
        fi
        PROMPT="%F{cyan}%~%f$(git_seg)$sym "
      }

      # Integração fzf
      if command -v fzf >/dev/null 2>&1; then
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        source ${pkgs.fzf}/share/fzf/completion.zsh
      fi
    '';
  };

  # bat e fzf configurados
  programs.bat.enable = true;

  home.packages = with pkgs; [
    fzf
    bat
    fd
    tree
  ];

  home.sessionVariables = {
    FZF_DEFAULT_OPTS = "--info=inline-right --ansi --layout=reverse --border=rounded --height=60%";
    FZF_CTRL_T_COMMAND = "fd --type f --hidden --follow --exclude .git || find . -type f";
    FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=numbers --line-range=:500 {}'";
    FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'";
  };
}
