# DevShells - Ambientes de Desenvolvimento

## 🎯 O que são DevShells?

DevShells são **ambientes de desenvolvimento isolados** definidos no `flake.nix`. Diferente das ferramentas instaladas globalmente no sistema, eles:

- ✅ São ativados por demanda com `nix develop`
- ✅ Não poluem o sistema global
- ✅ Permitem versões diferentes por projeto
- ✅ São reproduzíveis entre máquinas
- ✅ Perfeitos para CI/CD

## � Estrutura Modular

As DevShells foram extraídas para um arquivo dedicado para manter o `flake.nix` limpo:

```
/workspaces/nixos-config/
├── flake.nix          # ~130 linhas (importa devshells.nix)
├── devshells.nix      # ~280 linhas (definições completas)
├── core.nix
└── home.nix
```

**Benefícios:**
- ✅ `flake.nix` 60% menor e mais legível
- ✅ DevShells organizadas logicamente em um arquivo
- ✅ Separação de responsabilidades
- ✅ Manutenção simplificada

## �🚀 Shells Disponíveis

### 1. **Default** (desenvolvimento geral)
```bash
nix develop
# ou
nix develop .#default
```
Inclui o básico: Rust stable + Go + Node.js

---

### 2. **Rust (stable)**
```bash
nix develop .#rust
```

**Inclui:**
- Rust stable (rustc, cargo)
- rust-analyzer, clippy, rustfmt
- cargo-edit, cargo-watch, cargo-make, cargo-nextest
- clang, openssl, zlib

**Ideal para:** Projetos Rust em produção

---

### 3. **Rust (nightly)**
```bash
nix develop .#rust-nightly
```

**Inclui:**
- Rust nightly via fenix
- Mesmas ferramentas do stable
- Recursos experimentais do Rust

**Ideal para:** Testar features nightly, projetos que precisam nightly

---

### 4. **Go**
```bash
nix develop .#go
```

**Inclui:**
- Go 1.25
- gopls (LSP), delve (debugger)
- gofumpt, golangci-lint
- go-task (task runner)
- air (hot reload)

**Ideal para:** Projetos Go com tooling completo

---

### 5. **Full Stack**
```bash
nix develop .#fullstack
```

**Inclui:**
- Rust stable + Go + Node.js
- Ferramentas essenciais de cada stack
- git, gh (GitHub CLI)

**Ideal para:** Projetos que usam múltiplas linguagens

---

### 6. **Lua**
```bash
nix develop .#lua
```

**Inclui:**
- Lua 5.4 + LuaJIT
- lua-language-server (LSP)
- stylua (formatter)
- selene (linter)
- luarocks (package manager)

**Ideal para:** Scripts Lua, Neovim plugins, game scripting

---

### 7. **Nix Development**
```bash
nix develop .#nix-dev
```

**Inclui:**
- nixpkgs-fmt, alejandra (formatters)
- nil, nixd (LSPs)
- statix, deadnix (linters)
- nix-tree, nix-diff (analysis)
- nix-init, nix-update (utilities)

**Ideal para:** Desenvolver módulos NixOS, flakes, derivations

---

## 📁 Uso por Projeto

### Opção 1: Ativar manualmente

```bash
cd meu-projeto-rust
nix develop /caminho/para/nixos-config#rust

# Agora tem Rust stable + ferramentas
cargo build
```

### Opção 2: `.envrc` com direnv (recomendado)

Crie `.envrc` na raiz do projeto:

```bash
# .envrc
use flake /home/borba/nixos-config#rust
```

Com `direnv` instalado:
```bash
direnv allow
# Ambiente ativa automaticamente ao entrar no diretório!
```

### Opção 3: `flake.nix` no projeto

Crie `flake.nix` no projeto:

```nix
{
  description = "Meu projeto Rust";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          rustc
          cargo
          # deps específicas do projeto
        ];
      };
    };
}
```

Depois:
```bash
nix develop  # Usa o flake.nix local
```

---

## 🔄 Estratégia Híbrida (Recomendada)

### Ferramentas Globais (sempre disponíveis)
Definidas em `modules/languages/`:
- **go.nix** → Go 1.25 + gopls + delve + tooling
- **rust.nix** → Rustup (stable + nightly) + cargo extensions
- **lua.nix** → Lua 5.4 + LuaJIT + LSP (toggle: `enableLua`)
- **nix-dev.nix** → Formatters, LSPs, linters para Nix
- **python.nix**, **nodejs.nix** → Outras linguagens

Ferramentas core em `modules/apps/dev-tools.nix`:
- Git, GitHub CLI

### DevShells (por projeto)
Definidos em `flake.nix`:
- Rust stable/nightly via fenix
- Go com tooling completo
- Lua com LSP e ferramentas
- Nix com análise e formatação
- Combinações específicas

**Resultado:**
- Terminal normal → ferramentas globais disponíveis
- `nix develop` → ambiente isolado com versões específicas

---

## 💡 Exemplos Práticos

### Backend Rust com API
```bash
cd ~/projetos/api-rust
nix develop /home/borba/nixos-config#rust

# Ambiente tem tudo para Rust
cargo init
cargo add axum tokio
cargo run
```

### Service Go com gRPC
```bash
cd ~/projetos/grpc-service
nix develop /home/borba/nixos-config#go

# Ambiente Go completo
go mod init github.com/user/grpc-service
go get google.golang.org/grpc
go run main.go
```

### Projeto Full Stack
```bash
cd ~/projetos/fullstack-app
nix develop /home/borba/nixos-config#fullstack

# Backend em Go
cd backend && go run .

# Frontend em Node.js
cd ../frontend && pnpm dev

# Worker em Rust
cd ../worker && cargo run
```

---

## 🛠️ Customização

### Adicionar dependências ao shell Rust

Edite `devshells.nix`:

```nix
devShells.rust = pkgs.mkShell {
  buildInputs = with pkgs; [
    rustStable
    # ... ferramentas existentes
    
    # Adicione suas deps:
    postgresql  # Para projetos com Postgres
    redis       # Para cache
    protobuf    # Para gRPC
  ];
};
```

### Criar shell para linguagem específica

Edite `devshells.nix` e adicione uma nova entrada:

```nix
devShells.python = pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    poetry
    python3Packages.pip
  ];
  
  shellHook = ''
    echo "🐍 Python Development"
    python --version
  '';
};
```

**Nota:** Todas as definições de DevShells estão em `devshells.nix`, não no `flake.nix`.

---

## 🆚 Global vs DevShell

| Aspecto | Global (`dev-tools.nix`) | DevShell (`flake.nix`) |
|---------|-------------------------|------------------------|
| **Disponibilidade** | Sempre | Ao rodar `nix develop` |
| **Versão** | Uma por linguagem | Múltiplas possíveis |
| **Uso** | CLI geral, scripts | Projetos específicos |
| **Isolamento** | Compartilhado | Isolado por shell |
| **Reinstalação** | nixos-rebuild | Instantâneo |

---

## 📚 Recursos

- [Nix DevShells](https://nixos.wiki/wiki/Development_environment_with_nix-shell)
- [Fenix (Rust toolchains)](https://github.com/nix-community/fenix)
- [direnv integration](https://direnv.net/)

---

## ⚡ Quick Reference

```bash
# Listar shells disponíveis
nix flake show

# Entrar em shell específico
nix develop .#rust
nix develop .#rust-nightly
nix develop .#go
nix develop .#lua
nix develop .#nix-dev
nix develop .#fullstack

# Com direnv (auto-ativa)
echo "use flake .#rust" > .envrc
direnv allow

# Ver o que está no shell
nix develop .#rust --command which rustc
nix develop .#go --command go env
nix develop .#lua --command lua5.4 -v

# Rodar comando dentro do shell
nix develop .#rust --command cargo build
nix develop .#go --command go test ./...
nix develop .#lua --command lua script.lua
```
