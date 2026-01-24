# modules/apps/git.nix
{ config, pkgs, lib, ... }:

{
  # Ativa o pacote git
  programs.git.enable = true;

  # Pacotes relacionados
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    bat     # usado como pager
    delta   # diff bonito (recomendado)
    tig     # TUI git (opcional)
  ];

  # Config declarativa para git via systemd user service (cria ~/.config/git/config e ignore)
  systemd.user.services."git-config-setup" = {
    description = "Setup declarative git config and ignore files";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      mkdir -p "$HOME/.config/git"

      # ~/.config/git/config
      cat > "$HOME/.config/git/config" << 'EOF'
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
      EOF

      # ~/.config/git/ignore
      cat > "$HOME/.config/git/ignore" << 'EOF'
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
      EOF

      chmod 600 "$HOME/.config/git/config"
      chmod 600 "$HOME/.config/git/ignore"
    '';
  };
}
