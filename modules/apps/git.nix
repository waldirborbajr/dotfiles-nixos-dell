# modules/apps/git.nix
{ config, pkgs, lib, ... }:

{
  # Ativa o git (pacote + binário no PATH)
  programs.git.enable = true;

  # Config global do git (~/.config/git/config)
  xdg.configFile."git/config".text = ''
    [user]
        name = Waldir Borba Junior
        email = wborbajr@gmail.com

    [core]
        editor = nvim
        pager = bat
        autocrlf = input

    [init]
        defaultBranch = main

    [pull]
        rebase = true

    [push]
        default = current
        autoSetupRemote = true

    [fetch]
        prune = true
        pruneTags = true

    [rebase]
        autoStash = true
        autoSquash = true

    [merge]
        conflictStyle = zdiff3

    [alias]
        st = status --short --branch
        co = checkout
        br = branch -v
        ci = commit
        cm = commit -m
        ca = commit --amend
        lg = log --graph --oneline --decorate --all
        df = diff --color-words
        ds = diff --staged
        fp = fetch --prune --prune-tags
        pu = push --set-upstream origin HEAD
        rh = reset --hard HEAD
        undo = reset --soft HEAD~1
  '';

  # Arquivo global de ignores (~/.config/git/ignore)
  xdg.configFile."git/ignore".text = ''
    # Editores / temporários
    *.swp *.swo *.swn *~ .fuse_hidden*
    .DS_Store

    # Ambientes virtuais / deps
    .venv/ venv/ __pycache__/ *.pyc
    node_modules/ .npm/ .yarn/ dist/ build/

    # DevOps / Infra
    .terraform/ *.tfstate *.tfstate.backup
    .kube/ k8s/ *.kubeconfig
    .direnv/ .envrc
    *.log *.tmp *.bak

    # Tags / ctags
    tags TAGS cscope.*

    # Outros comuns
    .env .env.local .env.*
    .cache/ .pytest_cache/
  '';

  # Pacotes essenciais + ferramentas úteis
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    bat           # pager do git
    delta         # diff bonito (recomendado)
    tig           # interface TUI para git (opcional)
  ];

  # Opcional: força delta como pager padrão do git (diffs lindos)
  environment.variables.GIT_PAGER = "delta";
}
