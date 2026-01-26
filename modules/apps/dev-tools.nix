# modules/apps/dev-tools.nix
# Consolidado: git + gh + go + rust
{ config, pkgs, lib, ... }:

{
  # ========================================
  # Git
  # ========================================
  programs.git = {
    enable = true;

    settings.user = {
      name = "Waldir Borba Junior";
      email = "wborbajr@gmail.com";
    };

    settings.core.editor = "nvim";

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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
      line-numbers = true;
      navigate = true;
      theme = "Monokai Extended";
    };
  };

  programs.git.settings = {
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
      wip     = "commit -m 'WIP' --no-verify";
      fixup   = "commit --fixup=HEAD";
      squash  = "rebase -i --autosquash";
      amend   = "commit --amend --no-edit";
      last    = "log -1 --pretty=%B";
      who     = "shortlog -sn --since='1 week ago'";
      graph   = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      gone    = "!git fetch --prune && git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
      cleanup = "!git branch --merged main | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
      pr      = "!f() { git fetch origin pull/$1/head:pr/$1 && git checkout pr/$1; }; f";
      sync    = "!git fetch --prune && git rebase origin/$(git branch --show-current)";
      tags    = "tag --sort=-v:refname";
      remotes = "remote -v";
      fresh   = "fetch --all --prune && git pull --rebase";
      mr      = "merge --no-ff";
    };
  };

  # ========================================
  # GitHub CLI
  # ========================================
  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "ssh";
      editor = "";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      pager = "";

      aliases = {
        co        = "pr checkout";
        pv        = "pr view --web";
        pi        = "pr create --fill --web";
        il        = "issue list --limit 20";
        ic        = "issue create --web";
        prm       = "pr merge --squash --delete-branch";
        prd       = "pr merge --delete-branch";
        prr       = "pr ready";
        prc       = "pr checks";
        prs       = "pr status";
        repo      = "repo view --web";
        rcl       = "repo clone";
        rl        = "release list";
        rc        = "release create --generate-notes";
        rw        = "workflow list";
        rwr       = "workflow run";
        auth      = "auth status";
        who       = "api user --jq '.login'";
        prl       = "pr list --limit 20";
        draft     = "pr create --draft --fill";
        review    = "pr review --approve";
        "merge-auto" = "pr merge --auto --squash";
      };
    };
  };

  # ========================================
  # Go
  # ========================================
  home.packages = with pkgs; [
    git
    git-lfs
    delta
    tig
    gh
    gh-dash
    go_1_25
    gopls
    delve
    gotools
    gofumpt
    golangci-lint
    rustup
    cargo-edit
    cargo-watch
    cargo-make
    cargo-nextest
  ];

  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN  = "${config.home.homeDirectory}/go/bin";
  };

  # ========================================
  # Aliases consolidados
  # ========================================
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    # Go aliases
    goi   = "go install ./...";
    got   = "go test ./... -v";
    gotc  = "go test -coverprofile=cover.out ./...";
    goc   = "go clean -cache -modcache";
    goup  = "go get -u ./...";
    gom   = "go mod tidy";
    gorf  = "gofumpt -w .";
    gol   = "golangci-lint run";
    
    # Rust aliases
    ru    = "rustup update";
    rc    = "cargo check";
    rb    = "cargo build --release";
    rt    = "cargo test -- --nocapture";
    rtw   = "cargo watch -x 'test -- --nocapture'";
    rr    = "cargo run --release";
    rf    = "cargo fmt";
    rl    = "cargo clippy --all-targets -- -D warnings";
    ra    = "cargo add";
    ruu   = "cargo upgrade";
    rdoc  = "cargo doc --open";
  };

  # ========================================
  # Ativações
  # ========================================
  home.activation = {
    ensureGoPath = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/go/{bin,pkg,src}
    '';
    
    ensureRustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Lembrete: rode manualmente na primeira ativação:"
      echo "  rustup toolchain install stable"
      echo "  rustup default stable"
      echo "  rustup component add rust-analyzer rls rust-src rustfmt clippy"
    '';
  };
}
