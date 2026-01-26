# DevShells - Development Environments

## 🎯 What are DevShells?

DevShells are **isolated development environments** defined in `flake.nix`. Unlike globally installed system tools, they:

- ✅ Are activated on demand with `nix develop`
- ✅ Don't pollute the global system
- ✅ Allow different versions per project
- ✅ Are reproducible across machines
- ✅ Perfect for CI/CD

## 📦 Modular Structure

DevShells were extracted to a dedicated file to keep `flake.nix` clean:

```
/workspaces/nixos-config/
├── flake.nix          # ~130 lines (imports devshells.nix)
├── devshells.nix      # ~280 lines (complete definitions)
├── core.nix
└── home.nix
```

**Benefits:**
- ✅ `flake.nix` 60% smaller and more readable
- ✅ DevShells logically organized in one file
- ✅ Separation of concerns
- ✅ Simplified maintenance

## 🚀 Available Shells

### 1. **Default** (general development)
```bash
nix develop
# or
nix develop .#default
```
Includes the basics: Rust stable + Go + Node.js

---

### 2. **Rust (stable)**
```bash
nix develop .#rust
```

**Includes:**
- Rust stable (rustc, cargo)
- rust-analyzer, clippy, rustfmt
- cargo-edit, cargo-watch, cargo-make, cargo-nextest
- clang, openssl, zlib
- Database clients (psql, mysql, sqlite3)

**Ideal for:** Production Rust projects

---

### 3. **Rust (nightly)**
```bash
nix develop .#rust-nightly
```

**Includes:**
- Rust nightly via fenix
- Same tools as stable
- Experimental Rust features
- Database clients (psql, mysql, sqlite3)

**Ideal for:** Testing nightly features, projects requiring nightly

---

### 4. **Go**
```bash
nix develop .#go
```

**Includes:**
- Go 1.25
- gopls (LSP), delve (debugger)
- gofumpt, golangci-lint
- go-task (task runner)
- air (hot reload)
- Database clients (psql, mysql, sqlite3)

**Ideal for:** Go projects with complete tooling

---

### 5. **Full Stack**
```bash
nix develop .#fullstack
```

**Includes:**
- Rust stable + Go + Node.js
- Essential tools from each stack
- git, gh (GitHub CLI)

**Ideal for:** Projects using multiple languages

---

### 6. **Lua**
```bash
nix develop .#lua
```

**Includes:**
- Lua 5.4 + LuaJIT
- lua-language-server (LSP)
- stylua (formatter)
- selene (linter)
- luarocks (package manager)

**Ideal for:** Lua scripts, Neovim plugins, game scripting

---

### 7. **Nix Development**
```bash
nix develop .#nix-dev
```

**Includes:**
- nixpkgs-fmt, alejandra (formatters)
- nil, nixd (LSPs)
- statix, deadnix (linters)
- nix-tree, nix-diff (analysis)
- nix-init, nix-update (utilities)

**Ideal for:** Developing NixOS modules, flakes, derivations

---

### 8. **DevOps**
```bash
nix develop .#devops
```

**Includes:**
- Container tools: k9s, cri-tools
- Kubernetes: kubectl, helm, kubectx, stern
- Infrastructure as Code: terraform, ansible
- Workflow: commitizen, devcontainer

**Ideal for:** DevOps workflows, Kubernetes management, Infrastructure automation

**Note:** Docker/Podman runtime is managed separately in `modules/virtualization/`

---

### 9. **PostgreSQL**
```bash
nix develop .#postgresql
```

**Includes:**
- PostgreSQL (server + client)
- pgcli (interactive client with autocomplete)
- pgFormatter (SQL formatter)

**Ideal for:** Projects using PostgreSQL, schema development

**Quick start:**
```bash
mkdir -p $HOME/.postgres
initdb -D $HOME/.postgres/data
pg_ctl -D $HOME/.postgres/data -l logfile start
createdb mydb
psql mydb
```

---

### 10. **MariaDB**
```bash
nix develop .#mariadb
```

**Includes:**
- MariaDB (server + client)
- mycli (interactive client with autocomplete)
- mysqldump, mysqlshow

**Ideal for:** Projects using MySQL/MariaDB

**Quick start:**
```bash
mkdir -p $HOME/.mariadb
mysql_install_db --datadir=$HOME/.mariadb/data
mysqld --datadir=$HOME/.mariadb/data --socket=/tmp/mysql.sock &
mysql -u root
```

---

### 11. **SQLite**
```bash
nix develop .#sqlite
```

**Includes:**
- SQLite (CLI)
- litecli (interactive client)
- sqlitebrowser (GUI)

**Ideal for:** Local development, prototypes, embedded applications

**Quick start:**
```bash
sqlite3 mydb.db
# or with enhanced interface
litecli mydb.db
```

---

### 12. **All Databases**
```bash
nix develop .#databases
```

**Includes:**
- PostgreSQL + tools
- MariaDB + tools
- SQLite + tools

**Ideal for:** Projects working with multiple databases

---

## 🔗 Database + Language Integration

**Go and Rust shells already include database clients!**

When activating `.#rust` or `.#go`, you have available:
- ✅ `psql` (PostgreSQL client)
- ✅ `mysql` (MariaDB client)
- ✅ `sqlite3` (SQLite client)

**Practical example:**
```bash
# Terminal 1: Activate Go shell
nix develop .#go

# Terminal 2: Start database in another shell
nix develop .#postgresql
initdb -D $HOME/.postgres/data
pg_ctl -D $HOME/.postgres/data start
createdb myapp

# Terminal 1: Connect from Go shell
psql myapp
go run main.go  # Your Go app can connect to PostgreSQL
```

---

## 📁 Project Usage

### Option 1: Manual activation

```bash
cd my-rust-project
nix develop /path/to/nixos-config#rust

# Now you have Rust stable + tools
cargo build
```

### Option 2: `.envrc` with direnv (recommended)

Create `.envrc` in project root:

```bash
# .envrc
use flake /home/user/nixos-config#rust
```

With `direnv` installed:
```bash
direnv allow
# Environment activates automatically when entering directory!
```

### Option 3: `flake.nix` in project

Create `flake.nix` in project:

```nix
{
  description = "My Rust project";
  
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
          # project-specific deps
        ];
      };
    };
}
```

Then:
```bash
nix develop  # Uses local flake.nix
```

---

## 🔄 Hybrid Strategy (Recommended)

### Global Tools (always available)
Defined in `modules/languages/`:
- **go.nix** → Go 1.25 + gopls + delve + tooling
- **rust.nix** → Rustup (stable + nightly) + cargo extensions
- **lua.nix** → Lua 5.4 + LuaJIT + LSP (toggle: `enableLua`)
- **nix-dev.nix** → Formatters, LSPs, linters for Nix
- **python.nix**, **nodejs.nix** → Other languages

Core tools in `modules/apps/dev-tools.nix`:
- Git, GitHub CLI

### DevShells (per project)
Defined in `devshells.nix`:
- Rust stable/nightly via fenix
- Go with complete tooling
- Lua with LSP and tools
- Nix with analysis and formatting
- Specific combinations

**Result:**
- Normal terminal → global tools available
- `nix develop` → isolated environment with specific versions

---

## 💡 Practical Examples

### Rust Backend with API
```bash
cd ~/projects/rust-api
nix develop /home/user/nixos-config#rust

# Environment has everything for Rust
cargo init
cargo add axum tokio
cargo run
```

### Go Service with gRPC
```bash
cd ~/projects/grpc-service
nix develop /home/user/nixos-config#go

# Complete Go environment
go mod init github.com/user/grpc-service
go get google.golang.org/grpc
go run main.go
```

### Full Stack Project
```bash
cd ~/projects/fullstack-app
nix develop /home/user/nixos-config#fullstack

# Backend in Go
cd backend && go run .

# Frontend in Node.js
cd ../frontend && pnpm dev

# Worker in Rust
cd ../worker && cargo run
```

### Rust API + PostgreSQL
```bash
cd ~/projects/rust-api
nix develop /home/user/nixos-config#rust

# Terminal 1: Start PostgreSQL
nix develop /home/user/nixos-config#postgresql
initdb -D $HOME/.postgres/data
pg_ctl -D $HOME/.postgres/data start
createdb myapi

# Terminal 2: Develop the API
cargo add sqlx tokio
cargo sqlx migrate run
cargo run
```

### Go Microservice + MariaDB
```bash
cd ~/projects/go-service
nix develop /home/user/nixos-config#go

# MySQL client already available
mysql -h localhost -u root
go run main.go
```

---

## 🛠️ Customization

### Add dependencies to Rust shell

Edit `devshells.nix`:

```nix
devShells.rust = pkgs.mkShell {
  buildInputs = with pkgs; [
    rustStable
    # ... existing tools
    
    # Add your deps:
    postgresql  # For Postgres projects
    redis       # For cache
    protobuf    # For gRPC
  ];
};
```

### Create shell for specific language

Edit `devshells.nix` and add a new entry:

```nix
devShells.python = pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    poetry
    python3Packages.pip
    
    # Database clients (optional)
    postgresql
    mariadb-client
    sqlite
  ];
  
  shellHook = ''
    echo "🐍 Python Development"
    python --version
  '';
};
```

### Add specific database to a shell

If you want only PostgreSQL in Rust shell:

```nix
devShells.rust-postgres = pkgs.mkShell {
  buildInputs = with pkgs; [
    rustStable
    # ... other tools
    
    # Only PostgreSQL
    postgresql
    pgcli
  ];
};
```

**Note:** All DevShell definitions are in `devshells.nix`, not in `flake.nix`.

---

## 🆚 Global vs DevShell

| Aspect | Global (`dev-tools.nix`) | DevShell (`devshells.nix`) |
|---------|-------------------------|------------------------|
| **Availability** | Always | When running `nix develop` |
| **Version** | One per language | Multiple possible |
| **Usage** | General CLI, scripts | Specific projects |
| **Isolation** | Shared | Isolated per shell |
| **Reinstallation** | nixos-rebuild | Instant |

---

## 📚 Resources

- [Nix DevShells](https://nixos.wiki/wiki/Development_environment_with_nix-shell)
- [Fenix (Rust toolchains)](https://github.com/nix-community/fenix)
- [direnv integration](https://direnv.net/)

---

## ⚡ Quick Reference

```bash
# List available shells
nix flake show

# Languages
nix develop .#rust          # Rust stable + DB clients
nix develop .#rust-nightly  # Rust nightly + DB clients
nix develop .#go            # Go + DB clients
nix develop .#lua           # Lua development
nix develop .#nix-dev       # Nix tooling
nix develop .#fullstack     # Rust + Go + Node

# Databases
nix develop .#postgresql    # PostgreSQL + tools
nix develop .#mariadb       # MariaDB + tools
nix develop .#sqlite        # SQLite + tools
nix develop .#databases     # All databases

# With direnv (auto-activate)
echo "use flake .#rust" > .envrc
direnv allow

# See what's in the shell
nix develop .#rust --command which rustc
nix develop .#go --command go env
nix develop .#postgresql --command psql --version

# Run command inside shell
nix develop .#rust --command cargo build
nix develop .#go --command go test ./...
nix develop .#postgresql --command psql mydb
```
