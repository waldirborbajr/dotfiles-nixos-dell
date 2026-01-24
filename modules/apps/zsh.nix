# modules/apps/zsh.nix
{ config, pkgs, lib, ... }:

let
  # Script pequeno pra status do git (rápido e sem firula).
  # Mostra: branch + indicadores: * (dirty) + (staged) ? (untracked) ⇡⇣ (ahead/behind)
  gitPrompt = pkgs.writeShellScript "zsh-git-prompt" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Só roda se estiver num repo
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      exit 0
    fi

    # branch (ou short sha se detached)
    branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || true)"
    [ -n "''${branch:-}" ] || exit 0

    # status rápido (porcelana)
    st="$(git status --porcelain=v1 2>/dev/null || true)"

    dirty=""
    staged=""
    untracked=""

    if echo "$st" | grep -qE '^[ MARC?DU][MD] '; then staged="+"; fi
    if echo "$st" | grep -qE '^[MDARC?DU][ MD] '; then dirty="*"; fi
    if echo "$st" | grep -qE '^\?\? '; then untracked="?"; fi

    # ahead/behind (pode falhar se não tiver upstream; ok)
    ahead=""
    behind=""
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
      counts="$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || true)"
      left="''${counts%% *}"
      right="''${counts##* }"
      if [ "''${left:-0}" != "0" ]; then ahead="⇡"; fi
      if [ "''${right:-0}" != "0" ]; then behind="⇣"; fi
    fi

    printf "%s%s%s%s%s" "$branch" "$staged" "$dirty" "$untracked" "$ahead$behind"
  '';
in
{
  #### Zsh habilitado pelo NixOS ####
  programs.zsh.enable = true;

  #### Ferramentas usadas pelo teu workflow (sem exagero) ####
  environment.systemPackages = with pkgs; [
    git
    fzf
    zoxide
    eza
    bat
  ];

  #### Variáveis globais (login shells) ####
  environment.etc."zsh/zprofile".text = ''
    # /etc/zsh/zprofile (Nix-managed)
    export EDITOR=nvim
    export VISUAL=nvim
    export SUDO_EDITOR=nvim
    export FCEDIT=nvim
    export BROWSER=com.brave.Browser

    # Terminal default (se quiser)
    export TERMINAL=kitty

    # PATHs pessoais (somente se existirem, sem poluir nem duplicar)
    pathappend() {
      for p in "$@"; do
        [ -d "$p" ] || continue
        case ":$PATH:" in
          *":$p:"*) ;;
          *) PATH="$PATH:$p" ;;
        esac
      done
    }

    pathprepend() {
      for p in "$@"; do
        [ -d "$p" ] || continue
        case ":$PATH:" in
          *":$p:"*) ;;
          *) PATH="$p:$PATH" ;;
        esac
      done
    }

    pathprepend "$HOME/.local/bin" "$HOME/bin" "$HOME/.bin"
    pathappend "$HOME/go/bin" "$HOME/.cargo/bin"
  '';

  #### Zsh interativo (prompt, aliases, binds) ####
  environment.etc."zsh/zshrc".text = ''
    # /etc/zsh/zshrc (Nix-managed)
    setopt autocd correct interactivecomments magicequalsubst nonomatch notify numericglobsort promptsubst
    setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

    HISTSIZE=10000
    SAVEHIST=10000
    HISTFILE="$HOME/.zsh_history"

    # Vi mode
    bindkey -v
    bindkey "^[[A" history-beginning-search-backward
    bindkey "^[[B" history-beginning-search-forward

    # Completion
    autoload -Uz compinit && compinit
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    zstyle ':completion:*' menu no

    # bat como pager/manpager quando disponível
    if command -v bat >/dev/null 2>&1; then
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"
      export PAGER=bat
    fi

    # FZF opts (mantive simples pra DevOps, sem tema pesado)
    if command -v fzf >/dev/null 2>&1; then
      export FZF_DEFAULT_OPTS="--info=inline-right --ansi --layout=reverse --border=rounded"
    fi

    # zoxide
    if command -v zoxide >/dev/null 2>&1; then
      eval "$(zoxide init --cmd cd zsh)"
    fi

    # Aliases essenciais (enxutos)
    alias c='clear'
    alias q='exit'
    alias ll='eza -lg --icons --group-directories-first'
    alias la='eza -lag --icons --group-directories-first'
    alias rg="rg --hidden --smart-case --glob='!.git/' --no-search-zip --trim"

    # Git (curto e objetivo)
    alias gs='git status --short'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gu='git pull'
    alias gd='git diff'
    alias gds='git diff --staged'

    # Função "runfree"
    runfree() { "$@" >/dev/null 2>&1 & disown; }

    # Prompt: caminho + git status rápido
    # Ex: ~/repo/subdir [main+*?⇡]
    git_seg() {
      local s
      s="$(${gitPrompt} 2>/dev/null)"
      [ -n "$s" ] && echo " [%F{magenta}$s%f]"
    }

    # Prompt minimalista (DevOps)
    # Mostra status do comando anterior via cor do símbolo
    precmd() {
      local code=$?
      local sym
      if [ $code -eq 0 ]; then
        sym="%F{green}❯%f"
      else
        sym="%F{red}❯%f"
      fi
      PROMPT="%F{cyan}%~%f$(git_seg)\n$sym "
    }

    # ---- Opcional: auto iniciar tmux (igual teu alacritty) ----
    # Descomenta se quiser sempre entrar no tmux "DevOps" ao abrir shell interativo
    # if command -v tmux >/dev/null 2>&1; then
    #   if [[ -z "$TMUX" && -z "$SSH_CONNECTION" ]]; then
    #     tmux new-session -A -D -s DevOps
    #   fi
    # fi
  '';

  #### (Opcional) zshenv mínimo: só XDG paths (NÃO coloque coisa pesada aqui) ####
  environment.etc."zsh/zshenv".text = ''
    # /etc/zsh/zshenv (Nix-managed) - keep minimal!
    export ZDOTDIR="$HOME"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_STATE_HOME="$HOME/.local/state"
  '';
}