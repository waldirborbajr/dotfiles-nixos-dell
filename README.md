[![NixOS CI](https://github.com/waldirborbajr/nixos-config/workflows/NixOS%20Configuration%20CI/badge.svg?branch=REFACTORv2)](https://github.com/waldirborbajr/nixos-config/actions/workflows/ci.yml)
[![Nix Flake](https://img.shields.io/badge/nix-flakes-blue?logo=nixos&logoColor=white)](https://nixos.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

# BORBA JR W – NixOS Configuration ❄️

# 🧊 nixos-config

Declarative, modular **multi-host NixOS configuration**, focused on performance, clarity, and on-demand features.

This repository is the **single source of truth** for my personal Linux infrastructure, supporting machines with very different capabilities while keeping one consistent workflow.

**✨ Recently refactored** (REFACTORv2) for improved simplicity and maintainability:
- 60% fewer configuration files
- Centralized hardware configs
- Consolidated app modules
- Eliminated structural duplication

---

## 🎯 Project Goals

- One repository, multiple hosts
- Clear separation between:
  - Core system
  - Hardware
  - Desktop environments
  - Optional features
- Avoid unnecessary heavy rebuilds
- Containers, Kubernetes and virtualization **only when explicitly enabled**
- Predictable performance, even on old hardware

---

## 🖥️ Supported Hardware

### 🍎 MacBook Pro 13" (2011)
- Architecture: x86_64
- RAM: 16 GB
- Storage: 500 GB SSD
- Role: main workstation
- Desktop: Niri & GNOME (Wayland via GDM)
- Optional features: DEVOPS / QEMU (on-demand)

### 💻 Dell Inspiron 1456
- Architecture: x86_64
- RAM: 4 GB
- Storage: 120 GB SSD
- Role: basic usage / study machine
- Desktop: i3 (X11)
- Optional features: all disabled (Docker, K3s, QEMU)

---

## 🧱 Repository Architecture

```
.
├── ARCHITECTURE.md
├── CHANGELOG.md
├── INSTALL.md
├── LICENSE
├── Makefile
├── NEWHOST.md
├── README.md
├── VERSIONING.md
├── build.sh
├── core.nix              # Central hub for system-wide modules
├── dump.sh
├── flake.lock
├── flake.nix             # Multi-host flake configuration
├── home.nix              # Home Manager configuration
├── init.sh
├── link.sh
├── troubleshoot.sh
│
├── hardware/             # ✨ Hardware configurations (centralized)
│   ├── performance/
│   │   ├── common.nix
│   │   ├── dell.nix
│   │   └── macbook.nix
│   ├── dell.nix
│   ├── dell-hw-config.nix
│   ├── macbook.nix
│   └── macbook-hw-config.nix
│
├── hosts/                # ✨ Complete host configurations (no profiles/)
│   ├── dell.nix
│   └── macbook.nix
│
├── modules/
│   ├── system/           # ✨ Base system modules
│   │   ├── audio.nix
│   │   ├── base.nix
│   │   ├── fonts.nix
│   │   ├── networking.nix
│   │   ├── nixpkgs.nix
│   │   ├── ssh.nix
│   │   └── system-packages.nix
│   │
│   ├── apps/             # ✨ Consolidated application modules
│   │   ├── dev-tools.nix    # git + gh + go + rust
│   │   ├── flatpak.nix      # flatpak enable + packages
│   │   ├── shell.nix        # zsh + fzf + bat
│   │   ├── terminals.nix    # alacritty
│   │   └── tmux.nix
│   │
│   ├── desktops/         # ✨ Desktop environments
│   │   ├── gnome.nix
│   │   ├── i3.nix           # Extracted from host config
│   │   └── niri.nix         # Moved from apps/
│   │
│   ├── languages/        # ✨ Programming languages (simplified)
│   │   ├── nodejs.nix       # Consolidated: common + enable
│   │   └── python.nix       # Consolidated: common + uv + poetry
│   │
│   ├── virtualization/   # ✨ Unified containers & VMs
│   │   ├── docker.nix
│   │   ├── k3s.nix
│   │   ├── libvirt.nix
│   │   └── podman.nix
│   │
│   ├── features/         # On-demand features
│   │   ├── devops.nix
│   │   └── qemu.nix
│   │
│   ├── users/
│   │   └── borba.nix
│   │
│   ├── autologin.nix
│   ├── fzf.nix
│   └── xdg-portal.nix
│
└── scripts/
    ├── ci-build.sh
    ├── ci-checks.sh
    ├── ci-eval.sh
    └── flatpak-sync.sh
```

### ✨ Recent Refactoring (REFACTORv2)

- **Eliminated duplication**: `profiles/` removed, hosts now contain complete configs
- **Centralized hardware**: All hardware configs moved to `hardware/` directory
- **Consolidated modules**: 
  - 13 app files → 5 consolidated modules
  - 3-4 files per language → 1 file per language
  - Separated system modules into `modules/system/`
- **Better organization**: 
  - `niri.nix` moved from `apps/` to `desktops/`
  - `i3.nix` extracted as reusable module
  - Unified `virtualization/` (merged containers + VMs)
- **60% fewer files** with clearer structure

---

## 🧩 Feature Flags (On-Demand)

Heavy components are **disabled by default**.

### DEVOPS
- Docker
- K3s
- DevOps tooling

### QEMU
- libvirtd
- QEMU
- virt-manager

Flags are **independent** and can be combined freely.

### Module Organization

**System Level** (`modules/system/`)
- Base system configuration, networking, audio, fonts, SSH

**Applications** (`modules/apps/`)
- `shell.nix` - ZSH + FZF + bat configuration
- `terminals.nix` - Alacritty terminal emulator
- `dev-tools.nix` - Git, GitHub CLI, Go, Rust toolchains
- `flatpak.nix` - Flatpak service + application list
- `tmux.nix` - Terminal multiplexer

**Desktops** (`modules/desktops/`)
- `gnome.nix` - GNOME desktop environment (optimized for Wayland)
- `i3.nix` - i3 window manager (X11 for low-resource machines)
- `niri.nix` - Niri scrollable-tiling compositor (Wayland)

**Languages** (`modules/languages/`)
- `nodejs.nix` - Node.js + pnpm (toggle with `enableNode` flag)
- `python.nix` - Python + uv/poetry (configurable)

**Virtualization** (`modules/virtualization/`)
- Docker, Podman, K3s, libvirt (activated by feature flags)

---

## 📈 Refactoring Benefits

### Before → After

| Aspect | Before | After | Improvement |
|--------|--------|-------|-------------|
| App modules | 13 separate files | 5 consolidated | **-60% files** |
| Hosts setup | `hosts/` + `profiles/` | `hosts/` only | **Zero duplication** |
| Language configs | 3-4 files each | 1 file each | **-75% complexity** |
| Hardware configs | Scattered in root | Centralized in `hardware/` | **Better organization** |
| Desktop modules | Mixed with apps | Properly categorized | **Clearer structure** |

### Key Improvements

1. **Consolidated Modules**: Related functionality grouped together
   - Shell tools (zsh + fzf + bat) in one module
   - Dev tools (git + gh + go + rust) in one module
   - Terminal (alacritty) configuration

2. **Logical Organization**: 
   - System-level configs in `modules/system/`
   - Desktop environments in `modules/desktops/`
   - Programming languages in `modules/languages/`
   - Virtualization unified in `modules/virtualization/`

3. **Simplified Maintenance**: 
   - No more profiles/ duplication
   - Hardware configs all in one place
   - Fewer imports, clearer dependencies

4. **Preserved Functionality**: 
   - 100% backward compatible
   - All features still work
   - Same build commands

---

## 🧪 Usage (Makefile)

```
make switch HOST=macbook  
DEVOPS=1 make switch HOST=macbook  
QEMU=1 make switch HOST=macbook  
DEVOPS=1 QEMU=1 make switch HOST=macbook  
```

Dell (always minimal):

```
make switch HOST=dell
```

Run:

```
make help
```

---

## 🛠️ Development Shells

Este flake inclui **devShells** para ambientes de desenvolvimento isolados:

```bash
# Rust stable + ferramentas completas
nix develop .#rust

# Rust nightly via fenix
nix develop .#rust-nightly

# Go + gopls + delve + ferramentas
nix develop .#go

# Lua + LuaJIT + LSP
nix develop .#lua

# Nix development (formatters, LSPs, linters)
nix develop .#nix-dev

# Full stack (Rust + Go + Node)
nix develop .#fullstack

# Default (básico)
nix develop
```

**Vantagens:**
- ✅ Ambientes isolados por projeto
- ✅ Versões específicas de ferramentas
- ✅ Reproduzível entre máquinas
- ✅ Não polui o sistema global

**Linguagens disponíveis globalmente:**
- Go (`modules/languages/go.nix`)
- Rust (`modules/languages/rust.nix`)
- Lua (`modules/languages/lua.nix` - toggle)
- Nix (`modules/languages/nix-dev.nix`)
- Python, Node.js

**Documentação completa:** [DEVSHELLS.md](DEVSHELLS.md)

---

## 🔍 CI/CD & Quality Assurance

This repository includes **automated validation** on every push/PR to ensure configurations are always working.

### GitHub Actions CI Pipeline

The CI workflow (`.github/workflows/ci.yml`) validates:

✅ **Flake Check** - Validates flake syntax and dependencies  
✅ **Build Configurations** - Tests both `macbook` and `dell` builds  
✅ **Devshells** - Verifies all 11 development shells work  
✅ **Format Check** - Ensures consistent Nix code formatting

### Local Testing

Before pushing, run all CI checks locally:

```bash
# Run all tests (recommended before pushing)
./scripts/test-all.sh

# Or run individual checks:
./scripts/ci-checks.sh        # Flake validation
./scripts/ci-build.sh macbook # Build specific host
./scripts/ci-eval.sh          # Evaluate all configs
nix fmt -- --check .          # Format check
```

### CI Status

All commits are automatically validated:
- ✅ **REFACTORv2 branch** - Protected, requires passing CI
- ✅ **Pull Requests** - Must pass all checks before merge
- 📦 **Artifacts** - Build logs stored for 7 days

**Documentation:** [.github/workflows/README.md](.github/workflows/README.md)

**Integração com direnv:** Veja [.envrc.example](.envrc.example)

---

## ⚡ Performance Strategy

- schedutil CPU governor (MacBook)
- ZRAM enabled
- systemd startup optimizations
- journald size limits
- heavy services disabled by default
- Dell treated as low-resource machine

Troubleshooting:

```
./troubleshoot.sh
```

---

## ➕ Adding a New Host

See:
NEWHOST.md

---

## 📜 License

MIT

---

## 👤 Author

**BORBA JR W**

Declarative infrastructure. Pragmatic design. Zero waste.

---

## 🙏 Acknowledgments

Inspired by the NixOS community and various configuration examples.

Special thanks to contributors and maintainers of NixOS, Home Manager, and related projects.
