# modules/apps/git.nix
{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    userName  = "Waldir Borba Junior";
    userEmail = "wborbajr@gmail.com";

    # Editor padrão
    extraConfig.core.editor = "nvim";

    # Pager bonito com delta (recomendado para diffs legíveis)
    delta = {
      enable = true;
      options = {
        side-by-side = true;
        line-numbers = true;
        navigate = true;
        theme = "Monokai Extended";  # mude para "GitHub" se preferir light/dark
      };
    };

    # Configurações úteis e aliases expandidos para DevOps
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

        # DevOps / Trabalho diário (expandidos)
        wip     = "commit -m 'WIP' --no-verify";                     # commit rápido sem hooks
        fixup   = "commit --fixup=HEAD";                             # prepara para rebase -i --autosquash
        squash  = "rebase -i --autosquash";                          # squash commits pendentes
        amend   = "commit --amend --no-edit";                        # amend sem editar mensagem
        last    = "log -1 --pretty=%B";                              # mensagem do último commit
        who     = "shortlog -sn --since='1 week ago'";               # commits por autor na semana
        graph   = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        gone    = "!git fetch --prune && git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";  # deleta merged remotas
        cleanup = "!git branch --merged main | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";  # limpa merged locais
        pr      = "!f() { git fetch origin pull/$1/head:pr/$1 && git checkout pr/$1; }; f";  # checkout PR (ex: git pr 42)
        sync    = "!git fetch --prune && git rebase origin/$(git branch --show-current)";  # sync upstream
        tags    = "tag --sort=-v:refname";                           # tags ordenadas por versão
        remotes = "remote -v";                                       # lista remotes com URLs
        fresh   = "fetch --all --prune && git pull --rebase";        # atualiza tudo
        mr      = "merge --no-ff";                                   # merge sem fast-forward (útil para reviews)
      };
    };

    # .gitignore global
    ignores = [
      "*.swp" "*.swo" "*.swn" "*~" ".fuse_hidden*"
      ".DS_Store"
      ".venv/" "venv/" "__pycache__/" "*.pyc"
      "node_modules/" ".npm/" ".yarn/" "dist/" "build/"
      ".terraform/" "*.tfstate" "*.tfstate.backup"
      ".kube/" "k8s/" "*.kubeconfig"
      ".direnv/" ".envrc"
      "*.log" "*.tmp" "*.bak"
      "tags" "TAGS" "cscope.*"
      ".env" ".env.local" ".env.*"
      ".cache/" ".pytest_cache/"
    ];
  };

  # Pacotes relacionados (delta para pager, tig para TUI, git-lfs se precisar)
  home.packages = with pkgs; [
    git
    git-lfs
    delta
    tig     # opcional: git tig para visualização TUI
  ];
}
