# modules/apps/git.nix
{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    userName  = "Waldir Borba Junior";
    userEmail = "wborbajr@gmail.com";

    # Editor padrão
    extraConfig.core.editor = "nvim";

    # Pager bonito com delta (substitui bat em diffs)
    delta = {
      enable = true;
      options = {
        side-by-side = true;
        line-numbers = true;
        navigate = true;
        theme = "Monokai Extended";  # ou "GitHub", "Dracula", etc.
      };
    };

    # Configurações comuns e úteis
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
      };
      rebase = {
        autoStash = true;
        autoSquash = true;
      };
      merge.conflictStyle = "zdiff3";
      core.autocrlf = "input";
      alias = {
        # Básicos
        st   = "status --short --branch";
        co   = "checkout";
        br   = "branch -v";
        ci   = "commit";
        cm   = "commit -m";
        ca   = "commit --amend";
        lg   = "log --graph --oneline --decorate --all";
        df   = "diff --color-words";
        ds   = "diff --staged";
        fp   = "fetch --prune --prune-tags";
        pu   = "push --set-upstream origin HEAD";
        rh   = "reset --hard HEAD";
        undo = "reset --soft HEAD~1";

        # DevOps / Trabalho diário (mais úteis)
        wip  = "commit -m 'WIP' --no-verify";                     # commit rápido sem lint/pre-commit
        fixup = "commit --fixup=HEAD";                             # prepara fixup para rebase
        squash = "rebase -i --autosquash";                         # squash commits pendentes
        amend = "commit --amend --no-edit";                        # amend sem editar mensagem
        last = "log -1 --pretty=%B";                               # mostra mensagem do último commit
        who  = "shortlog -sn --since='1 week ago'";                # quem commitou mais na semana
        graph = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        gone = "fetch --prune && git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";  # deleta branches merged remotamente
        cleanup = "!git branch --merged main | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";  # limpa branches locais merged
        pr   = "!f() { git fetch origin pull/$1/head:pr/$1 && git checkout pr/$1; }; f";  # checkout de PR (ex: git pr 42)
        sync = "!git fetch --prune && git rebase origin/$(git branch --show-current)";  # sync com upstream
        tags = "tag --sort=-v:refname";                            # lista tags ordenadas por versão
        remotes = "remote -v";                                     # lista remotes com URLs
      };
    };

    # .gitignore global
    ignores = [
      # Editores / temporários
      "*.swp" "*.swo" "*.swn" "*~" ".fuse_hidden*"
      ".DS_Store"

      # Ambientes virtuais / deps
      ".venv/" "venv/" "__pycache__/" "*.pyc"
      "node_modules/" ".npm/" ".yarn/" "dist/" "build/"

      # DevOps / Infra
      ".terraform/" "*.tfstate" "*.tfstate.backup"
      ".kube/" "k8s/" "*.kubeconfig"
      ".direnv/" ".envrc"
      "*.log" "*.tmp" "*.bak"

      # Tags / ctags
      "tags" "TAGS" "cscope.*"

      # Outros comuns
      ".env" ".env.local" ".env.*"
      ".cache/" ".pytest_cache/"
    ];
  };

  # Pacotes relacionados
  home.packages = with pkgs; [
    git
    git-lfs
    delta   # pager bonito
    tig     # TUI git (opcional, mas útil)
  ];
}
