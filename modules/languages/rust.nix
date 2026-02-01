# modules/languages/rust.nix
# Rust development environment
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.languages.rust.enable {
    # ========================================
    # Rust packages (global via rustup)
    # ========================================
    home.packages = with pkgs; [
      rustup # Toolchain manager (stable + nightly)
      cargo-edit # cargo add, cargo rm, cargo upgrade
      cargo-watch # cargo watch -x test
      cargo-make # Task runner
      cargo-nextest # Next-gen test runner
      cargo-expand # Expand macros
      cargo-outdated # Check outdated dependencies
    ];

    # ========================================
    # Shell aliases
    # ========================================
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      ru = "rustup update";
      rc = "cargo check";
      rb = "cargo build --release";
      rt = "cargo test -- --nocapture";
      rtw = "cargo watch -x 'test -- --nocapture'";
      rr = "cargo run --release";
      rrd = "cargo run"; # debug mode
      rf = "cargo fmt";
      rl = "cargo clippy --all-targets -- -D warnings";
      ra = "cargo add";
      ruu = "cargo upgrade";
      rdoc = "cargo doc --open";
      rexp = "cargo expand";
      rnew = "cargo new";
      rinit = "cargo init";
    };

    # ========================================
    # Home activation (rustup setup reminder)
    # ========================================
    home.activation = {
      ensureRustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "$HOME/.rustup" ]; then
          echo "========================================="
          echo "⚠️  Rustup Setup Required"
          echo "========================================="
          echo "Run these commands to complete Rust setup:"
          echo ""
          echo "  rustup toolchain install stable"
          echo "  rustup default stable"
          echo "  rustup component add rust-analyzer rust-src rustfmt clippy"
          echo ""
          echo "Optional (for nightly features):"
          echo "  rustup toolchain install nightly"
          echo "========================================="
        fi
      '';
    };
  };
}
