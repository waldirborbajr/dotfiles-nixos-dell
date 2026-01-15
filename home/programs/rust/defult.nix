{ config, pkgs, ... }:

let
  # Diretórios padrão do rustup (equivalente ao GOPATH/GOBIN)
  RUSTUP_HOME   = "${config.home.homeDirectory}/.rustup";
  CARGO_HOME    = "${config.home.homeDirectory}/.cargo";
  CARGO_BIN     = "${CARGO_HOME}/bin";
in
{
  # Instala rustup (o gerenciador oficial de toolchains Rust)
  home.packages = with pkgs; [
    rustup          # instala rustup + cargo + rustc inicial
    # Opcional: instale rust-analyzer separadamente se preferir versão pinned do nixpkgs
    # rust-analyzer
  ];

  # Configura variáveis de ambiente para Rust (semelhante ao env do Go)
  home.sessionVariables = {
    RUSTUP_HOME   = RUSTUP_HOME;
    CARGO_HOME    = CARGO_HOME;
  };

  # Adiciona ~/.cargo/bin ao PATH (para cargo, rustc, etc.)
  home.sessionPath = [
    CARGO_BIN
  ];

  # Opcional: inicializa rustup com toolchain padrão ao ativar o home-manager
  # (executa só na primeira ativação ou quando mudar)
  home.activation = {
    installRustToolchain = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      # Instala a toolchain stable + componentes comuns se não existir
      if [ ! -f "${RUSTUP_HOME}/toolchains/stable-x86_64-unknown-linux-gnu/bin/rustc" ]; then
        ${pkgs.rustup}/bin/rustup toolchain install stable
        ${pkgs.rustup}/bin/rustup component add rust-src rust-analyzer clippy rustfmt
        ${pkgs.rustup}/bin/rustup default stable
      fi
    '';
  };

  # Opcional: aliases úteis para o shell (adicione no seu programs.zsh se quiser)
  # programs.zsh.shellAliases = {
  #   ru     = "rustup";
  #   cb     = "cargo build";
  #   cr     = "cargo run";
  #   ct     = "cargo test";
  #   cf     = "cargo fmt";
  #   clippy = "cargo clippy";
  # };
}