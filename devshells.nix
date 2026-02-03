# devshells.nix
# Development shells for multiple languages and toolchains
# Usage: nix develop .#rust | .#go | .#lua | .#nix-dev | .#fullstack
{ nixpkgs-stable, fenix, flake-utils }:

flake-utils.lib.eachDefaultSystem (system:
let
  pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };

  fenixPkgs = fenix.packages.${system};

  # Rust toolchains
  rustStable = fenixPkgs.stable.withComponents [
    "rustc"
    "cargo"
    "clippy"
    "rustfmt"
    "rust-analyzer"
    "rust-src"
  ];

  rustNightly = fenixPkgs.complete.withComponents [
    "rustc"
    "cargo"
    "clippy"
    "rustfmt"
    "rust-analyzer"
    "rust-src"
  ];
in
{
  # ==========================================
  # DevShell: Rust (stable)
  # ==========================================
  devShells.rust = pkgs.mkShell {
    name = "rust-dev-stable";

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      rustStable
      cargo-edit
      cargo-watch
      cargo-make
      cargo-nextest

      # Common build dependencies
      clang
      llvmPackages.bintools
      openssl
      zlib

      # Database clients
      postgresql
      mariadb.client
      sqlite
      usql
      pgcli
      mycli
      litecli
    ];

    RUST_SRC_PATH = "${rustStable}/lib/rustlib/src/rust/library";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

    shellHook = ''
      echo "🦀 Rust Development Environment (stable)"
      echo "Rust version: $(rustc --version)"
      echo "Cargo version: $(cargo --version)"
      echo ""
      echo "Available tools:"
      echo "  - cargo-edit, cargo-watch, cargo-make, cargo-nextest"
      echo "  - clippy, rustfmt, rust-analyzer"
      echo ""
      echo "Database clients available:"
      echo "  - usql (universal SQL client)"
      echo "  - pgcli (PostgreSQL)"
      echo "  - mycli (MySQL/MariaDB)"
      echo "  - litecli (SQLite)"
    '';
  };

  # ==========================================
  # DevShell: Rust (nightly)
  # ==========================================
  devShells.rust-nightly = pkgs.mkShell {
    name = "rust-dev-nightly";

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      rustNightly
      cargo-edit
      cargo-watch
      cargo-make
      cargo-nextest

      # Database clients
      postgresql
      mariadb.client
      sqlite
      usql
      pgcli
      mycli
      litecli
    ];

    RUST_SRC_PATH = "${rustNightly}/lib/rustlib/src/rust/library";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

    shellHook = ''
      echo "🦀 Rust Development Environment (nightly)"
      echo "Rust version: $(rustc --version)"
      echo "Cargo version: $(cargo --version)"
      echo ""
      echo "Database clients available:"
      echo "  - usql (universal SQL client)"
      echo "  - pgcli (PostgreSQL)"
      echo "  - mycli (MySQL/MariaDB)"
      echo "  - litecli (SQLite)"
    '';
  };

  # ==========================================
  # DevShell: Go
  # ==========================================
  devShells.go = pkgs.mkShell {
    name = "go-dev";

    buildInputs = with pkgs; [
      go_1_25
      gopls
      delve
      gotools
      gofumpt
      golangci-lint
      go-task
      air # Hot reload

      # Database clients
      postgresql
      mariadb.client
      sqlite
      usql
      pgcli
      mycli
      litecli
    ];

    shellHook = ''
      echo "🐹 Go Development Environment"
      echo "Go version: $(go version)"
      echo ""
      echo "Environment:"
      echo "  GOPATH=$GOPATH"
      echo "  GOBIN=$GOBIN"
      echo ""
      echo "Available tools:"
      echo "  - gopls, delve, gofumpt, golangci-lint"
      echo "  - go-task (task runner), air (hot reload)"
      echo ""
      echo "Database clients available:"
      echo "  - usql (universal SQL client)"
      echo "  - pgcli (PostgreSQL)"
      echo "  - mycli (MySQL/MariaDB)"
      echo "  - litecli (SQLite)"
    '';

    # Go environment
    GOPATH = "${builtins.getEnv "HOME"}/go";
    GOBIN = "${builtins.getEnv "HOME"}/go/bin";
  };

  # ==========================================
  # DevShell: Full Stack (Rust + Go + Node)
  # ==========================================
  devShells.fullstack = pkgs.mkShell {
    name = "fullstack-dev";

    buildInputs = with pkgs; [
      # Rust
      rustStable
      cargo-edit
      cargo-watch

      # Go
      go_1_25
      gopls
      delve

      # Node.js
      nodejs_20
      nodePackages.pnpm

      # Tools
      git
      gh
    ];

    shellHook = ''
      echo "🚀 Full Stack Development Environment"
      echo "Rust: $(rustc --version)"
      echo "Go: $(go version)"
      echo "Node: $(node --version)"
    '';
  };

  # ==========================================
  # DevShell: Lua
  # ==========================================
  devShells.lua = pkgs.mkShell {
    name = "lua-dev";

    buildInputs = with pkgs; [
      lua5_4
      luajit
      luarocks
      lua-language-server
      stylua
      selene
    ];

    shellHook = ''
      echo "🌙 Lua Development Environment"
      echo "Lua: $(lua5.4 -v)"
      echo "LuaJIT: $(luajit -v)"
      echo ""
      echo "Available tools:"
      echo "  - lua-language-server (LSP)"
      echo "  - stylua (formatter)"
      echo "  - selene (linter)"
      echo "  - luarocks (package manager)"
    '';

    LUA_PATH = "${builtins.getEnv "HOME"}/.luarocks/share/lua/5.4/?.lua;${builtins.getEnv "HOME"}/.luarocks/share/lua/5.4/?/init.lua;;";
    LUA_CPATH = "${builtins.getEnv "HOME"}/.luarocks/lib/lua/5.4/?.so;;";
  };

  # ==========================================
  # DevShell: Nix Development
  # ==========================================
  devShells.nix-dev = pkgs.mkShell {
    name = "nix-dev";

    buildInputs = with pkgs; [
      nixpkgs-fmt
      alejandra
      nil
      nixd
      nix-tree
      nix-diff
      nix-update
      nix-init
      statix
      deadnix
    ];

    shellHook = ''
      echo "❄️  Nix Development Environment"
      echo "Tools: nixpkgs-fmt, alejandra, nil, nixd"
      echo "  - nix-tree, nix-diff, nix-update, nix-init"
      echo "  - statix (linter), deadnix (find dead code)"
    '';
  };

  # ==========================================
  # DevShell: Secrets Management (SOPS)
  # ==========================================
  devShells.secrets = pkgs.mkShell {
    name = "secrets-management";

    buildInputs = with pkgs; [
      sops
      age
      ssh-to-age
    ];

    shellHook = ''
      echo "🔐 Secrets Management Environment"
      echo ""
      echo "SOPS + Age tools available:"
      echo "  - sops: Edit encrypted secrets"
      echo "  - age: Generate age keys"
      echo "  - ssh-to-age: Convert SSH keys to age format"
      echo ""
      echo "Quick commands:"
      echo "  sops secrets/common/secrets.yaml    → Edit encrypted file"
      echo "  sops -d secrets/common/secrets.yaml → View decrypted"
      echo ""
      echo "Generate age key from SSH:"
      echo "  mkdir -p ~/.config/sops/age"
      echo "  ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
      echo "  chmod 600 ~/.config/sops/age/keys.txt"
      echo ""
      echo "See SECRETS-QUICKSTART.md for complete guide"
    '';
  };

  # ==========================================
  # DevShell: PostgreSQL
  # ==========================================
  devShells.postgresql = pkgs.mkShell {
    name = "postgresql-dev";

    buildInputs = with pkgs; [
      postgresql
      pgcli # PostgreSQL CLI with autocomplete
      pgformatter # SQL formatter (lowercase)
      usql # Universal SQL client
    ];

    shellHook = ''
      echo "🐘 PostgreSQL Development Environment"
      echo "PostgreSQL version: $(psql --version)"
      echo ""
      echo "Available tools:"
      echo "  - psql (client)"
      echo "  - pgcli (interactive client)"
      echo "  - usql (universal SQL client)"
      echo "  - pg_format (SQL formatter)"
      echo ""
      echo "Quick start local server:"
      echo "  mkdir -p \$HOME/.postgres"
      echo "  initdb -D \$HOME/.postgres/data"
      echo "  pg_ctl -D \$HOME/.postgres/data -l logfile start"
      echo "  createdb mydb"
      echo "  psql mydb"
    '';
  };

  # ==========================================
  # DevShell: MariaDB
  # ==========================================
  devShells.mariadb = pkgs.mkShell {
    name = "mariadb-dev";

    buildInputs = with pkgs; [
      mariadb
      mycli # MySQL/MariaDB CLI with autocomplete
      usql # Universal SQL client
    ];

    shellHook = ''
      echo "🐬 MariaDB Development Environment"
      echo "MariaDB version: $(mysql --version)"
      echo ""
      echo "Available tools:"
      echo "  - mysql (client)"
      echo "  - mycli (interactive client)"
      echo "  - usql (universal SQL client)"
      echo "  - mysqldump, mysqlshow"
      echo ""
      echo "Quick start local server:"
      echo "  mkdir -p \$HOME/.mariadb"
      echo "  mysql_install_db --datadir=\$HOME/.mariadb/data"
      echo "  mysqld --datadir=\$HOME/.mariadb/data --socket=/tmp/mysql.sock &"
      echo "  mysql -u root"
    '';
  };

  # ==========================================
  # DevShell: SQLite
  # ==========================================
  devShells.sqlite = pkgs.mkShell {
    name = "sqlite-dev";

    buildInputs = with pkgs; [
      sqlite
      sqlitebrowser # GUI for SQLite
      litecli # SQLite CLI with autocomplete
      usql # Universal SQL client
    ];

    shellHook = ''
      echo "💾 SQLite Development Environment"
      echo "SQLite version: $(sqlite3 --version)"
      echo ""
      echo "Available tools:"
      echo "  - sqlite3 (CLI)"
      echo "  - litecli (interactive CLI)"
      echo "  - usql (universal SQL client)"
      echo "  - sqlitebrowser (GUI)"
      echo ""
      echo "Quick start:"
      echo "  sqlite3 mydb.db"
      echo "  litecli mydb.db"
    '';
  };

  # ==========================================
  # DevShell: All Databases
  # ==========================================
  devShells.databases = pkgs.mkShell {
    name = "databases-dev";

    buildInputs = with pkgs; [
      # Universal SQL client
      usql

      # PostgreSQL
      postgresql
      pgcli
      pgformatter

      # MariaDB
      mariadb
      mycli

      # SQLite
      sqlite
      litecli
      sqlitebrowser
    ];

    shellHook = ''
      echo "🗄️  Databases Development Environment"
      echo ""
      echo "Available databases:"
      echo "  PostgreSQL: $(psql --version | head -n1)"
      echo "  MariaDB: $(mysql --version | head -n1)"
      echo "  SQLite: $(sqlite3 --version)"
      echo ""
      echo "Available clients:"
      echo "  - usql (universal SQL client)"
      echo "  - psql, pgcli (PostgreSQL)"
      echo "  - mysql, mycli (MariaDB)"
      echo "  - sqlite3, litecli (SQLite)"
    '';
  };

  # ==========================================
  # DevShell: DevOps Tools
  # ==========================================
  devShells.devops = pkgs.mkShell {
    name = "devops";

    buildInputs = with pkgs; [
      # Container tools
      k9s
      cri-tools

      # Development workflow
      commitizen
      devcontainer

      # Kubernetes
      kubectl
      kubernetes-helm
      kubectx
      kubecolor
      stern

      # Infrastructure as Code
      terraform
      ansible
    ];

    shellHook = ''
      echo "🚀 DevOps Development Environment"
      echo ""
      echo "Container tools:"
      echo "  - k9s (Kubernetes TUI)"
      echo "  - cri-tools (crictl)"
      echo ""
      echo "Kubernetes:"
      echo "  - kubectl, helm, kubectx, stern"
      echo ""
      echo "IaC:"
      echo "  - terraform, ansible"
      echo ""
      echo "Workflow:"
      echo "  - commitizen (git commits)"
      echo "  - devcontainer (VS Code)"
    '';
  };

  # ==========================================
  # DevShell: Default
  # ==========================================
  devShells.default = pkgs.mkShell {
    name = "dev";

    buildInputs = with pkgs; [
      rustStable
      go_1_25
      nodejs_20
    ];

    shellHook = ''
      echo "💻 Default Development Environment"
      echo "Use specific shells for more tools:"
      echo "  nix develop .#rust         → Rust stable"
      echo "  nix develop .#rust-nightly → Rust nightly"
      echo "  nix develop .#go           → Go with extras"
      echo "  nix develop .#lua          → Lua + LuaJIT"
      echo "  nix develop .#nix-dev      → Nix development tools"
      echo "  nix develop .#secrets      → SOPS/Age secrets management"
      echo "  nix develop .#fullstack    → Rust + Go + Node"
      echo "  nix develop .#devops       → K8s, Terraform, Ansible"
      echo ""
      echo "Databases:"
      echo "  nix develop .#postgresql   → PostgreSQL + tools"
      echo "  nix develop .#mariadb      → MariaDB + tools"
      echo "  nix develop .#sqlite       → SQLite + tools"
      echo "  nix develop .#databases    → All databases"
    '';
  };
}
)
