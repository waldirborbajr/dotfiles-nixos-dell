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

- Desktop environment services (GNOME keyring, etc.)
- Hardware-specific packages (Wi-Fi tools, firmware)
- Insecure packages (if needed for specific hardware)
- Virtualization settings (already handled via DEVOPS/QEMU flags)

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

First, check for syntax errors:

```bash
make check
```

Then test build without applying changes:

```bash
make test-build HOST=<newhost>
```

### 5.2. Apply the configuration

Build and switch to the new host:

```bash
make switch HOST=<newhost>
```

**Feature flags** (optional):

```bash
# Enable DevOps tools (Docker, K3s, etc.)
make switch HOST=<newhost> DEVOPS=1

# Enable QEMU/KVM virtualization
make switch HOST=<newhost> QEMU=1

# Enable both
make switch HOST=<newhost> DEVOPS=1 QEMU=1

# Force impure evaluation (if using environment variables)
make switch HOST=<newhost> IMPURE=1
```

**Other useful commands:**

```bash
# Update flake.lock and rebuild (upgrade all packages)
make upgrade HOST=<newhost>

# Production build (with full checks)
make switch-prod HOST=<newhost>

# Dry run (see what would change)
make dry-switch HOST=<newhost>

# List available hosts
make hosts

# Check system health
make doctor
```

## Summary Checklist

To add a new host, you need to create these files:

- [ ] `hardware/<newhost>-hw-config.nix` (copy from `/etc/nixos/hardware-configuration.nix`)
- [ ] `hardware/<newhost>.nix` (hardware-specific settings)
- [ ] `hardware/performance/<newhost>.nix` (performance optimizations)
- [ ] `hosts/<newhost>.nix` (host configuration)
- [ ] Register host in `flake.nix` using `mkHost` function

Then run:

```bash
make check                    # Validate syntax
make test-build HOST=<newhost>  # Test build
make switch HOST=<newhost>      # Apply configuration
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
    ├── system/                        # System services
    ├── apps/                          # Applications
    └── virtualization/                # Virtualization options
```

## Troubleshooting

### Build fails with "host not found"
Run `make hosts` to see available hosts. Ensure your host is registered in `flake.nix`.

### Hardware not detected
Check that `hardware/<newhost>-hw-config.nix` is correctly copied from `/etc/nixos/hardware-configuration.nix`.

### Desktop environment doesn't start
Verify that you imported the correct desktop module in `hosts/<newhost>.nix` and set up the appropriate bootloader.

### Permission errors
Ensure you're running `make switch` (not `nixos-rebuild` directly) as it handles sudo correctly.

## Notes

- The Makefile automatically commits and pushes changes before rebuild
- Commit message format: `wip(makefile): YYYY-MM-DD HH:MM`
- Use `GIT_PUSH=0` to disable automatic push: `make switch HOST=<newhost> GIT_PUSH=0`
- DEVOPS and QEMU flags are passed as environment variables to the flake
- Use `make doctor` to validate your setup before building

---

If a machine fails, reinstalling it takes minutes, not days.
