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

    # Configurações básicas do histórico
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.cacheHome}/.zsh_history";  # ou ~/.zsh_history se preferir
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      expireDuplicatesFirst = true;
    };

    # Alternativa: se preferir manter no shellInit como estava
    # shellInit = ''
    #   setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
    #   HISTSIZE=10000
    #   SAVEHIST=10000
    #   HISTFILE=~/.zsh_history
    # '';

    shellAliases = {
      c      = "clear";
      q      = "exit";
      ll     = "eza -lg --icons --group-directories-first";
      la     = "eza -lag --icons --group-directories-first";
      rg     = "rg --hidden --smart-case --glob='!.git/' --no-search-zip --trim";
      gs     = "git status --short";
      ga     = "git add";
      gc     = "git commit";
      gp     = "git push";
      gu     = "git pull";
      gd     = "git diff";
      gds    = "git diff --staged";
      runfree = ''"$@" >/dev/null 2>&1 & disown'';
    };

    # Configurações que rodam no início da sessão interativa
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

      # bat como pager / manpager
      if command -v bat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
        export PAGER=bat
      fi

      # zoxide
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init --cmd cd zsh)"
      fi

      # Prompt customizado com git status
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
        # Sem quebra de linha explícita → tudo na mesma linha
        PROMPT="%F{cyan}%~%f$(git_seg) $sym "
      }
    '';

    # Opcional: plugins do zsh que você pode querer adicionar depois
    # plugins = [
    #   {
    #     name = "zsh-autosuggestions";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "zsh-users";
    #       repo = "zsh-autosuggestions";
    #       rev = "c3d4e576c9c86eac628a0b265c7b30f0caee0a47";
    #       sha256 = "sha256-B+KzIrM0VkpeOA3u+ve5HqkgmkyJ3+AwagAQQp6fTXc=";
    #     };
    #   }
    # ];
  };

  # Pacotes que são úteis para o shell / terminal (fzf sai daqui)
  home.packages = with pkgs; [
    git
    zoxide
    eza
    bat
    ripgrep
    # fzf → removido, vem via programs.fzf
  ];
}
