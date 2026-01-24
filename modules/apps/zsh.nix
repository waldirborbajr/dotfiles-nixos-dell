# modules/apps/zsh.nix
{ config, pkgs, lib, ... }:

let
  gitPrompt = pkgs.writeShellScriptBin "git-prompt" ''
    #!/usr/bin/env bash
    set -euo pipefail
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then exit 0; fi
    branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || true)"
    [ -n "''${branch:-}" ] || exit 0
    st="$(git status --porcelain=v1 2>/dev/null || true)"
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
      left="''${counts%% *}"
      right="''${counts##* }"
      if [ "''${left:-0}" != "0" ]; then ahead="⇡''${left}"; fi
      if [ "''${right:-0}" != "0" ]; then behind="⇣''${right}"; fi
    fi
    printf "%s%s%s%s%s" "$branch" "$staged" "$dirty" "$untracked" "$ahead$behind"
  '';
in
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

        # Branch name
        branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || true)"
        [ -n "$branch" ] || return 0

        # Status
        local st="$(git status --porcelain=v1 2>/dev/null || true)"
        dirty=""
        staged=""
        untracked=""
        if echo "$st" | grep -qE '^[ MARC?DU][MD] '; then staged="+"; fi
        if echo "$st" | grep -qE '^[MDARC?DU][ MD] '; then dirty="*"; fi
        if echo "$st" | grep -qE '^\?\? '; then untracked="?"; fi

        # Ahead / Behind (push / pull) – com números
        ahead=""
        behind=""
        if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
          counts="$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || true)"
          left="''${counts%% *}"
          right="''${counts##* }"
          [ "''${left:-0}" -gt 0 ] && ahead="⇡''${left}"
          [ "''${right:-0}" -gt 0 ] && behind="⇣''${right}"
        fi

        # Cores rápidas e visuais
        if [ -n "$ahead" ]; then
          color="%F{green}"    # verde = tem para subir (push)
        elif [ -n "$behind" ]; then
          color="%F{red}"      # vermelho = tem para baixar (pull)
        elif [ -n "$dirty$staged$untracked" ]; then
          color="%F{yellow}"   # amarelo = dirty/staged/untracked
        else
          color="%F{magenta}"  # magenta = clean
        fi

        # Monta o segmento
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

      # Integração fzf (só se disponível – loose coupling)
      if command -v fzf >/dev/null 2>&1; then
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        source ${pkgs.fzf}/share/fzf/completion.zsh
      fi
    '';
  };

  home.packages = with pkgs; [
    git
    fzf
    zoxide
    eza
    bat
    ripgrep
    fd
    tree
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    BROWSER = "com.brave.Browser";
    TERMINAL = "kitty";
    NPM_CONFIG_UPDATE_NOTIFIER = "false";
    NPM_CONFIG_FUND = "false";
    NPM_CONFIG_AUDIT = "false";
    PYTHONDONTWRITEBYTECODE = "1";
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
  };
}
