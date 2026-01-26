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
        
        # Build dependencies comuns
        clang
        llvmPackages.bintools
        openssl
        zlib
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
        
        clang
        llvmPackages.bintools
        openssl
        zlib
      ];

      RUST_SRC_PATH = "${rustNightly}/lib/rustlib/src/rust/library";
      LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
      
      shellHook = ''
        echo "🦀 Rust Development Environment (nightly)"
        echo "Rust version: $(rustc --version)"
        echo "Cargo version: $(cargo --version)"
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
        air  # Hot reload
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
        echo ""
        echo "Available tools:"
        echo "  Formatters: nixpkgs-fmt, alejandra"
        echo "  LSPs: nil, nixd"
        echo "  Analysis: nix-tree, nix-diff, statix, deadnix"
        echo "  Utilities: nix-update, nix-init"
        echo ""
        echo "Quick commands:"
        echo "  nixpkgs-fmt .     # Format all .nix files"
        echo "  statix check .    # Lint for issues"
        echo "  deadnix .         # Find dead code"
      '';

      NIX_PATH = "nixpkgs=${pkgs.path}";
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
        echo "Use shells específicos para mais ferramentas:"
        echo "  nix develop .#rust         → Rust stable"
        echo "  nix develop .#rust-nightly → Rust nightly"
        echo "  nix develop .#go           → Go com extras"
        echo "  nix develop .#lua          → Lua + LuaJIT"
        echo "  nix develop .#nix-dev      → Nix development tools"
        echo "  nix develop .#fullstack    → Rust + Go + Node"
      '';
    };
  }
)
