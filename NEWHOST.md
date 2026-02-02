# Adding a New Host to the NixOS Flake

This document explains, step by step, how to add a new machine (host) to this NixOS flake-based setup.

The process is simple and deterministic: you reuse the shared configuration and only adapt what is hardware-specific.

## 1. Install NixOS on the New Machine

Install NixOS normally using the official ISO (graphical or minimal).

After the first boot, NixOS will generate:

```
- /etc/nixos/hardware-configuration.nix
- /etc/nixos/configuration.nix
```

You will NOT use the generated configuration.nix directly.  
It is only useful as a reference.

## 2. Create Hardware Configuration Files

On the new machine, copy the hardware configuration file into the repository's `hardware/` directory:

```bash
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hardware/<newhost>-hw-config.nix
```

Replace `<newhost>` with a short, lowercase hostname (for example: thinkpad, workstation, server1).

Now create two additional hardware files:

### 2.1. Create `hardware/<newhost>.nix`

This file contains hardware-specific configurations (drivers, firmware, etc.):

```bash
cp ~/nixos-config/hardware/dell.nix ~/nixos-config/hardware/<newhost>.nix
```

Edit it to include hardware-specific settings:
- GPU drivers
- Wi-Fi drivers/firmware
- Bluetooth settings
- Kernel modules
- Hardware-specific packages

### 2.2. Create `hardware/performance/<newhost>.nix`

This file contains performance optimizations:

```bash
cp ~/nixos-config/hardware/performance/dell.nix ~/nixos-config/hardware/performance/<newhost>.nix
```

Edit it to configure:
- Display manager preferences
- VM/memory tuning
- ZRAM settings
- Power management

Commit all three files to the repository.

## 3. Create a New Host Definition

Create a new host file:

```bash
cp ~/nixos-config/hosts/macbook.nix ~/nixos-config/hosts/<newhost>.nix
```

Edit `hosts/<newhost>.nix` and adjust the following:

### Required changes

#### 3.1. System version
```nix
system.stateVersion = "25.11";  # Update if needed
```

#### 3.2. Hardware imports
Update all three hardware imports:
```nix
imports = [
  ../hardware/<newhost>.nix
  ../hardware/performance/<newhost>.nix
  ../hardware/<newhost>-hw-config.nix
  
  # Desktop environment (choose one or multiple)
  ../modules/desktops/gnome.nix
  # ../modules/desktops/i3.nix
  # ../modules/desktops/niri/system.nix
  
  # System configuration
  ../modules/system/base.nix
  ../modules/system/networking.nix
  # ../modules/system/audio.nix
  # ../modules/system/fonts.nix
  # ../modules/system/ssh.nix
  
  # Applications (optional)
  # ../modules/apps/dev-tools.nix
  # ../modules/apps/terminals.nix
  # ../modules/apps/shell.nix
  # ../modules/apps/tmux.nix
  # ../modules/apps/yazi.nix
  # ../modules/apps/ripgrep.nix
  # ../modules/apps/fastfetch.nix
  # ../modules/apps/chirp.nix
  # ../modules/apps/alacritty.nix
  # ../modules/apps/clipboard.nix
  
  # Development languages (optional)
  # ../modules/languages/nix-dev.nix
  # ../modules/languages/rust.nix
  # ../modules/languages/python.nix
  # ../modules/languages/nodejs.nix
  # ../modules/languages/go.nix
  # ../modules/languages/lua.nix
  
  # Virtualization (optional - already included in features)
  # ../modules/virtualization/docker.nix
  # ../modules/virtualization/podman.nix
  # ../modules/virtualization/libvirt.nix
  # ../modules/virtualization/k3s.nix
  
  # User-specific configuration
  # ../modules/users/borba.nix
];
```

#### 3.3. Hostname
```nix
networking.hostName = "<newhost>-nixos";
```

#### 3.4. Bootloader
Choose based on your firmware:

For **EFI/UEFI** systems:
```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```

For **Legacy BIOS** systems:
```nix
boot.loader.grub.enable = true;
boot.loader.grub.devices = [ "/dev/sda" ];  # Adjust device
```

#### 3.5. Keyboard layout
```nix
console.keyMap = "us";  # or "br-abnt2", etc.

services.xserver.xkb = {
  layout = "us";      # or "br", etc.
  variant = "";       # or "abnt2", etc.
};
```

### Optional changes

- **Desktop environment services** (GNOME keyring, etc.)
- **Hardware-specific packages** (Wi-Fi tools, firmware)
- **Insecure packages** (if needed for specific hardware)
- **Virtualization settings** (already handled via DEVOPS/QEMU flags)
- **User-specific modules** (import from `modules/users/`)
- **Application modules** (import from `modules/apps/`)
- **Language support** (import from `modules/languages/`)
- **System modules** (import from `modules/system/` as needed)
- **Themes** (import from `modules/themes/`)

## 4. Register the Host in flake.nix

Edit `flake.nix` and add a new entry under `nixosConfigurations`.

The system uses a `mkHost` helper function. Add your new host:

```nix
nixosConfigurations = {
  macbook = mkHost { hostname = "macbook"; system = "x86_64-linux"; };
  dell = mkHost { hostname = "dell"; system = "x86_64-linux"; };
  
  # Add your new host:
  <newhost> = mkHost { hostname = "<newhost>"; system = "x86_64-linux"; };
  # Or for ARM64/Apple Silicon/Raspberry Pi:
  # <newhost> = mkHost { hostname = "<newhost>"; system = "aarch64-linux"; };
};
```

**System architectures:**
- `x86_64-linux` - Intel/AMD 64-bit (most PCs and VMs)
- `aarch64-linux` - ARM 64-bit (Apple Silicon, Raspberry Pi 4+, ARM VMs)

This makes the host selectable via the flake.

## 6. Build the System on the New Machine

Clone the repository on the new machine:

```bash
git clone https://github.com/waldirborbajr/nixos-config.git
cd nixos-config
```

### 5.1. Validate the configuration

This project uses [just](https://github.com/casey/just) command runner.

First, check for syntax errors:

```bash
just check
```

Then test build without applying changes:

```bash
just test-build <newhost>
```

### 5.2. Apply the configuration

Build and switch to the new host:

```bash
just switch <newhost>
```

**Feature flags** (optional):

```bash
# Enable DevOps tools (Docker, K3s, etc.)
DEVOPS=1 just switch <newhost>

# Enable QEMU/KVM virtualization
QEMU=1 just switch <newhost>

# Enable both
DEVOPS=1 QEMU=1 just switch <newhost>

# Force impure evaluation (if using environment variables)
just switch <newhost> 1 1 1  # DEVOPS QEMU IMPURE
```

**Other useful commands:**

```bash
# Update flake.lock and rebuild (upgrade all packages)
just upgrade <newhost>

# Production build (with full checks)
just switch-prod <newhost>

# Dry run (see what would change)
just dry-switch <newhost>

# List available hosts
just hosts

# Check system health
just doctor

# Format Nix files
just fmt

# List system generations
just list-generations
```

## Available Modules

### Desktop Environments
- `modules/desktops/gnome.nix` - GNOME desktop
- `modules/desktops/i3.nix` - i3 window manager
- `modules/desktops/niri/system.nix` - Niri window manager with Dank Material Shell

### System Configuration
- `modules/system/base.nix` - Base system configuration
- `modules/system/audio.nix` - Audio system (PulseAudio/PipeWire)
- `modules/system/fonts.nix` - Font configuration
- `modules/system/networking.nix` - Network configuration
- `modules/system/nixpkgs.nix` - Nixpkgs configuration
- `modules/system/serial-devices.nix` - Serial device access
- `modules/system/ssh.nix` - SSH configuration
- `modules/system/system-packages.nix` - Common system packages

### Applications
- `modules/apps/dev-tools.nix` - Development tools
- `modules/apps/alacritty.nix` - Alacritty terminal emulator
- `modules/apps/shell.nix` - Shell configurations
- `modules/apps/clipboard.nix` - Screenshot and clipboard tools
- `modules/apps/tmux.nix` - Tmux terminal multiplexer
- `modules/apps/yazi.nix` - Yazi file manager
- `modules/apps/ripgrep.nix` - Ripgrep search tool
- `modules/apps/fastfetch.nix` - Fastfetch system info
- `modules/apps/chirp.nix` - Chirp application

### Development Languages
- `modules/languages/nix-dev.nix` - Nix development
- `modules/languages/rust.nix` - Rust toolchain
- `modules/languages/python.nix` - Python development
- `modules/languages/nodejs.nix` - Node.js development
- `modules/languages/go.nix` - Go development
- `modules/languages/lua.nix` - Lua development

### Virtualization & DevOps
- `modules/features/devops.nix` - DevOps tools (Docker, Kubernetes, etc.)
- `modules/features/qemu.nix` - QEMU/KVM virtualization
- `modules/virtualization/docker.nix` - Docker
- `modules/virtualization/podman.nix` - Podman
- `modules/virtualization/libvirt.nix` - Libvirt/KVM
- `modules/virtualization/k3s.nix` - K3s lightweight Kubernetes

### Other
- `modules/autologin.nix` - Auto-login configuration
- `modules/fzf.nix` - Fuzzy finder integration
- `modules/xdg-portal.nix` - XDG portal (required for some apps)
- `modules/themes/default.nix` - System theme configuration
- `modules/users/borba.nix` - User-specific configuration example

## Summary Checklist

To add a new host, you need to create these files:

- [ ] `hardware/<newhost>-hw-config.nix` (copy from `/etc/nixos/hardware-configuration.nix`)
- [ ] `hardware/<newhost>.nix` (hardware-specific settings)
- [ ] `hardware/performance/<newhost>.nix` (performance optimizations)
- [ ] `hosts/<newhost>.nix` (host configuration)
- [ ] Register host in `flake.nix` using `mkHost` function

Then run:

```bash
just check                   # Validate syntax
just test-build <newhost>    # Test build
just switch <newhost>        # Apply configuration
```

## Design Philosophy

- **Core logic is shared** - Common configurations in `core.nix` and modules
- **Hardware is isolated** - Each host has dedicated hardware configs in `hardware/`
- **Performance is tunable** - Per-host optimizations in `hardware/performance/`
- **Features are opt-in** - DEVOPS and QEMU enabled via environment variables
- **Desktop flexibility** - Multiple desktop environments can coexist
- **No Home-Manager dependency** - System-level configuration only (Home-Manager integrated but optional)
- **Fully reproducible** - Flake-based, deterministic builds

## File Structure Overview

```
nixos-config/
├── flake.nix                          # Main entry point, host registry
├── core.nix                           # Shared configuration for all hosts
├── home.nix                           # Home-Manager configuration
├── hardware/
│   ├── <host>-hw-config.nix          # Generated hardware config
│   ├── <host>.nix                     # Hardware-specific settings
│   └── performance/
│       └── <host>.nix                 # Performance optimizations
├── hosts/
│   └── <host>.nix                     # Host-specific configuration
└── modules/
    ├── desktops/                      # Desktop environments
    │   ├── gnome.nix
    │   ├── i3.nix
    │   └── niri/                      # Niri window manager & Dank Material Shell
    │       ├── system.nix
    │       ├── config.nix
    │       ├── keybindings.nix
    │       ├── animations.nix
    │       ├── layout.nix
    │       ├── waybar.nix
    │       ├── mako.nix
    │       ├── fuzzel.nix
    │       └── ... (other niri config files)
    ├── system/                        # System services & core config
    │   ├── base.nix
    │   ├── audio.nix
    │   ├── fonts.nix
    │   ├── networking.nix
    │   ├── nixpkgs.nix
    │   ├── serial-devices.nix
    │   ├── ssh.nix
    │   └── system-packages.nix
    ├── apps/                          # Applications
    │   ├── dev-tools.nix
    │   ├── terminals.nix
    │   ├── shell.nix
    │   ├── tmux.nix
    │   ├── yazi.nix
    │   ├── ripgrep.nix
    │   ├── fastfetch.nix
    │   └── chirp.nix
    ├── languages/                     # Development languages
    │   ├── nix-dev.nix
    │   ├── rust.nix
    │   ├── python.nix
    │   ├── nodejs.nix
    │   ├── go.nix
    │   └── lua.nix
    ├── features/                      # Feature flags
    │   ├── devops.nix                # Docker, K3s, etc.
    │   └── qemu.nix                  # KVM virtualization
    ├── virtualization/                # Virtualization options
    │   ├── docker.nix
    │   ├── podman.nix
    │   ├── libvirt.nix
    │   └── k3s.nix
    ├── themes/                        # System themes
    │   └── default.nix
    ├── users/                         # User-specific configs
    │   └── borba.nix
    ├── autologin.nix                  # Auto-login configuration
    ├── fzf.nix                        # Fuzzy finder
    └── xdg-portal.nix                 # XDG portal
```

## Troubleshooting

### Build fails with "host not found"
Run `just hosts` to see available hosts. Ensure your host is registered in `flake.nix`.

### Hardware not detected
Check that `hardware/<newhost>-hw-config.nix` is correctly copied from `/etc/nixos/hardware-configuration.nix`.

### Desktop environment doesn't start
Verify that you imported the correct desktop module in `hosts/<newhost>.nix` and set up the appropriate bootloader.

### Permission errors
Ensure you're running `just switch` (not `nixos-rebuild` directly) as it handles sudo correctly.

## Notes

- The justfile automatically commits and pushes changes before rebuild (controlled by `AUTO_GIT_COMMIT`)
- Commit message format: `wip(justfile): YYYY-MM-DD HH:MM`
- Use `GIT_PUSH=0` to disable automatic push: `GIT_PUSH=0 just switch <newhost>`
- DEVOPS and QEMU flags are passed as environment variables to the flake
- Use `just doctor` to validate your setup before building
- Old `Makefile` is still available but deprecated

---

If a machine fails, reinstalling it takes minutes, not days.
