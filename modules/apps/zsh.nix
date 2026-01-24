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
      if [ "''${left:-0}" != "0" ]; then ahead="⇡"; fi
      if [ "''${right:-0}" != "0" ]; then behind="⇣"; fi
    fi
    printf "%s%s%s%s%s" "$branch" "$staged" "$dirty" "$untracked" "$ahead$behind"
  '';
in
{
  programs.zsh = {
    enable = true;

    # Histórico (usando opções nativas do NixOS, mais idiomático)
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.cacheHome}/.zsh_history";  # ou use ~/.zsh_history se preferir não usar xdg
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      expireDuplicatesFirst = true;
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

    # Código que roda em shells interativos
    initExtra = ''
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

      # FZF: integração oficial + suas opções
      if command -v fzf >/dev/null 2>&1; then
        export FZF_DEFAULT_OPTS="--info=inline-right --ansi --layout=reverse --border=rounded --height=60%"

        # Integração key-bindings e completion do fzf (Ctrl+R, Ctrl+T, Alt+C)
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        source ${pkgs.fzf}/share/fzf/completion.zsh

        # Opcional: melhore o preview do Ctrl+T com bat (se quiser ver conteúdo dos arquivos)
        export FZF_CTRL_T_COMMAND="fd --type f --hidden --follow --exclude .git || find . -type f"
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

        # Opcional: preview para Alt+C (diretórios)
        export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
      fi

      # Prompt + git status
      git_seg() {
        local s
        s="$(${gitPrompt}/bin/git-prompt 2>/dev/null)"
        [ -n "$s" ] && echo " %F{magenta}$s%f"
      }

      precmd() {
        local code=$?
        local sym
        if [ $code -eq 0 ]; then
          sym="%F{green}❯%f"
        else
          sym="%F{red}❯%f"
        fi
        PROMPT="%F{cyan}%~%f$(git_seg) $sym "
      }
    '';
  };

  # Pacotes necessários (incluindo fzf agora)
  environment.systemPackages = with pkgs; [
    git
    fzf         # ← adicionado aqui
    zoxide
    eza
    bat
    ripgrep
    fd          # útil para FZF_CTRL_T_COMMAND (mais rápido que find)
    tree        # opcional, para preview de diretórios no Alt+C
  ];

  # Suas variáveis de ambiente (mantidas)
  environment.sessionVariables = {
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
