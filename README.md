[![NixOS CI](https://github.com/waldirborbajr/nixos-config/workflows/NixOS%20Configuration%20CI/badge.svg?branch=REFACTORv2)](https://github.com/waldirborbajr/nixos-config/actions/workflows/ci.yml)
[![Nix Flake](https://img.shields.io/badge/nix-flakes-blue?logo=nixos&logoColor=white)](https://nixos.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

# BORBA JR W – NixOS Configuration ❄️

# 🧊 nixos-config

Declarative, modular **multi-host NixOS configuration**, focused on performance, clarity, and on-demand features.

This repository is the **single source of truth** for my personal Linux infrastructure, supporting machines with very different capabilities while keeping one consistent workflow.

**✨ Architecture:** This configuration follows the **Dendritic Pattern** - a neural-inspired modular architecture where configuration flows from root (flake) through branches (profiles) to leaves (modules).

**Key features:**
- Hierarchical composition with profiles layer
- Option-based module activation (mkIf pattern)
- Clear separation between system and home-manager
- Aggregator pattern for module discovery
- ~95% alignment with NixOS module system best practices

**📖 Learn more:** [DENDRITIC-PATTERN.md](DENDRITIC-PATTERN.md)

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

> **This configuration implements the [Dendritic Pattern](DENDRITIC-PATTERN.md)** - an architectural approach inspired by neural dendrites, organizing configuration as a hierarchical tree from root to leaves with explicit activation at each connection point.

```
.
├── flake.nix             # 🌳 Root: Multi-host flake configuration
├── core.nix              # 🎯 Minimal core (themes, features, XDG)
├── home.nix              # 🏠 Home Manager with option-based config
│
├── profiles/             # 🌿 Dendritic profiles (composition layer)
│   ├── minimal.nix       # Base system (system modules + users)
│   ├── desktop.nix       # minimal + GUI capabilities
│   └── developer.nix     # desktop + virtualization
│
├── hosts/                # 🖥️  Host-specific configurations
│   ├── dell.nix          # Uses desktop profile
│   └── macbook.nix       # Uses developer profile
│
├── hardware/             # ⚙️  Hardware configurations
│   ├── performance/
│   │   ├── common.nix
│   │   ├── dell.nix
│   │   └── macbook.nix
│   ├── dell.nix
│   ├── dell-hw-config.nix
│   ├── macbook.nix
│   └── macbook-hw-config.nix
│
├── modules/              # 🧩 Modular components (all with options)
│   ├── system/           # System-level modules
│   │   ├── default.nix   # 🎛️  Aggregator with options
│   │   ├── base.nix      # config.system-config.base.enable
│   │   ├── networking.nix
│   │   ├── audio.nix
│   │   ├── fonts.nix
│   │   ├── ssh.nix
│   │   ├── system-packages.nix
│   │   └── serial-devices.nix
│   │
│   ├── apps/             # Home-manager apps
│   │   ├── default.nix   # 🎛️  Aggregator with options
│   │   ├── shell.nix     # config.apps.shell.enable
│   │   ├── alacritty.nix # config.apps.alacritty.enable
│   │   ├── dev-tools.nix # config.apps.dev-tools.enable
│   │   ├── browsers.nix
│   │   ├── clipboard.nix
│   │   ├── fastfetch.nix
│   │   ├── helix.nix
│   │   ├── neovim.nix
│   │   ├── ripgrep.nix
│   │   ├── yazi.nix
│   │   ├── tmux.nix
│   │   ├── starship.nix
│   │   ├── zellij.nix
│   │   └── media/
│   │       ├── audio.nix
│   │       ├── image.nix
│   │       └── video.nix
│   │
│   ├── languages/        # Home-manager languages
│   │   ├── default.nix   # 🎛️  Aggregator with options
│   │   ├── go.nix        # config.languages.go.enable
│   │   ├── rust.nix      # config.languages.rust.enable
│   │   ├── lua.nix       # config.languages.lua.enable
│   │   ├── nix-dev.nix   # config.languages.nix-dev.enable
│   │   ├── python.nix    # System-level (always on)
│   │   └── nodejs.nix    # System-level (always on)
│   │
│   ├── desktops/         # Desktop environments
│   │   ├── gnome.nix
│   │   ├── i3.nix
│   │   └── niri/         # Modular Niri compositor
│   │
│   ├── virtualization/   # Containers & VMs
│   │   ├── default.nix
│   │   ├── docker.nix
│   │   ├── podman.nix
│   │   ├── k3s.nix
│   │   └── libvirt.nix
│   │
│   ├── features/         # On-demand features
│   │   ├── devops.nix
│   │   └── qemu.nix
│   │
│   ├── themes/           # Centralized theming
│   │   └── default.nix
│   │
│   └── users/
│       └── borba.nix
│
├── scripts/              # CI/CD and testing
│   ├── ci-build.sh
│   ├── ci-checks.sh
│   ├── ci-eval.sh
│   └── test-all.sh
│
└── wallpapers/           # 🎨 Custom wallpapers
    ├── README.md         # Wallpaper documentation
    └── devops-dark.svg   # Current wallpaper (Surface 2 theme)
```

### ✨ Dendritic Pattern Architecture

**Dendritic Pattern** = Neural-inspired modular architecture where configuration flows from root (flake) through branches (profiles) to leaves (modules).

> **🧠 Inspired by neuroscience:** Like dendrites in neurons receive signals from synapses and transmit to the cell body, this architecture receives configuration from modules (synapses) and flows through profiles (dendrites) to the system (cell body).

#### Key Concepts:

1. **Profiles as Composition Layer**
   - `minimal.nix` → Base system essentials
   - `desktop.nix` → minimal + GUI capabilities
   - `developer.nix` → desktop + containerization

2. **Option-Based Activation**
   - Every module has `enable` option
   - Uses `mkIf config.*.enable` pattern
   - No forced imports, explicit activation

3. **Aggregator Pattern**
   - `modules/system/default.nix` → System options
   - `modules/apps/default.nix` → App options
   - `modules/languages/default.nix` → Language options

4. **Clear Layer Separation**
   ```
   flake.nix (root)
     ↓
   profiles/ (branches)
     ↓
   modules/ (leaves with options)
     ↓
   hosts/ (final composition)
   ```

#### Benefits:

- ✅ **Composable**: Mix and match profiles
- ✅ **Explicit**: Options make dependencies clear
- ✅ **Testable**: Each module can be enabled/disabled
- ✅ **Maintainable**: Changes isolated to specific modules
- ✅ **Scalable**: Easy to add new modules/profiles

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
- `alacritty.nix` - Alacritty terminal emulator (90% transparency, Catppuccin)
- `fastfetch.nix` - System info tool (auto-runs in Alacritty)
- `dev-tools.nix` - Git, GitHub CLI, development toolchains
- `tmux.nix` - Terminal multiplexer with custom keybindings
- `clipboard.nix` - Screenshot tools (ksnip, gnome-screenshot, grim/slurp/swappy)
- `browsers.nix` - Web browsers (Firefox, Chromium)
- `helix.nix` / `neovim.nix` - Modern text editors
- `media/` - Audio, image, and video tools

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

## 📈 Dendritic Architecture Benefits

### Architecture Evolution

| Pattern | V1 (Monolithic) | V2 (Consolidated) | V3 (Dendritic) |
|---------|----------------|-------------------|----------------|
| **Structure** | Flat imports | Grouped modules | Profile-based |
| **Activation** | Always on | Import-based | Option-based |
| **Composition** | Duplicated | Centralized | Layered |
| **Maintainability** | ⚠️ Hard | ✅ Better | ✅✅ Best |
| **Alignment** | ~40% | ~70% | **~95%** |

### Dendritic Pattern Advantages

1. **🌳 Hierarchical Composition**
   ```nix
   # Host imports profile, profile imports modules
   hosts/macbook.nix → profiles/developer.nix → modules/system/
   
   # Options control activation
   system-config.base.enable = true;
   apps.shell.enable = true;
   ```

2. **🎛️ Granular Control**
   - Every module has individual `enable` option
   - Conditional loading via `mkIf`
   - No forced dependencies

3. **🧩 True Modularity**
   - Add module = 1 file + 1 option
   - Remove module = disable option
   - Test module = toggle enable

4. **📚 Self-Documenting**
   - Options show available features
   - `default.nix` aggregators act as indexes
   - Clear dependency graph

### Code Example

**Before (Direct imports):**
```nix
imports = [
  ./modules/system/base.nix
  ./modules/apps/shell.nix
  # Always active, no control
];
```

**After (Dendritic with options):**
```nix
imports = [ ./profiles/minimal.nix ];

# Explicit activation
system-config.base.enable = true;
apps.shell.enable = true;
```

---

## 🛠️ Usage (justfile)

This project uses [just](https://github.com/casey/just) command runner for all operations.

> **Note:** The old `Makefile` is still available but deprecated. New features are only added to `justfile`.

### Quick Start

```bash
# List available commands
just

# List available hosts
just hosts

# Switch to new configuration
just switch macbook

# Build without switching
just build macbook

# Test build (dry-run)
just test-build macbook
```

### With Feature Flags

```bash
# Enable DEVOPS features (Docker, K3s)
DEVOPS=1 just switch macbook

# Enable QEMU/libvirt
QEMU=1 just switch macbook

# Enable both
DEVOPS=1 QEMU=1 just switch macbook
```

### Production & Advanced

```bash
# Production switch (with full validation)
just switch-prod macbook

# Upgrade system (update flake + switch)
just upgrade macbook

# Debug build with verbose output
just build-debug macbook

# Format Nix files
just fmt

# List system generations
just list-generations

# Rollback to previous generation
just rollback YES
```

### Discovery & Validation

```bash
# Check system health
just doctor

# Validate flake syntax
just check

# Evaluate host configuration
just eval-host macbook
```

**Dell** (minimal profile, always lightweight):

```bash
just switch dell
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

## 🎨 Custom Wallpapers

This configuration includes custom wallpapers optimized for development environments.

### Current Wallpaper

**devops-dark.svg** - DevOps-themed wallpaper with Surface 2 background (#585b70)
- 1920x1080 resolution (SVG, scales to any size)
- Neutral gray background for excellent terminal contrast
- Colorful DevOps icons (Docker 🐳, Kubernetes ☸, Git ⎇, NixOS ❄️)
- Technology badges: Rust 🦀, Go ⚡, Lua 🌙
- Pipeline visualization: CODE → BUILD → TEST → DEPLOY → MONITOR

### Adding Your Own Wallpaper

1. **Save your wallpaper** in the `wallpapers/` directory:
   ```bash
   wallpapers/my-wallpaper.jpg
   ```

2. **Update GNOME configuration** ([modules/desktops/gnome.nix](modules/desktops/gnome.nix)):
   ```nix
   # Line 82-83:
   picture-uri = "file:///etc/nixos/wallpapers/my-wallpaper.jpg";
   picture-uri-dark = "file:///etc/nixos/wallpapers/my-wallpaper.jpg";
   
   # Line 124:
   environment.etc."nixos/wallpapers/my-wallpaper.jpg".source = 
     ../../wallpapers/my-wallpaper.jpg;
   ```

3. **For niri**, update ([modules/desktops/niri/default.nix](modules/desktops/niri/default.nix)):
   ```nix
   # Line 46:
   home.file.".config/niri/wallpaper.jpg".source = 
     ../../../wallpapers/my-wallpaper.jpg;
   ```

4. **Rebuild your system:**
   ```bash
   just switch macbook
   ```

**Supported formats:** JPG, PNG, SVG, WebP

**Picture options** (GNOME):
- `"zoom"` - Fill screen (default)
- `"scaled"` - Scale to fit
- `"centered"` - Center image
- `"stretched"` - Stretch to fill
- `"spanned"` - Span across monitors

**📖 Full documentation:** [wallpapers/README.md](wallpapers/README.md)

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
