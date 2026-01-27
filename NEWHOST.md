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

## 2. Copy the Hardware Configuration into the Repo

On the new machine, copy the hardware configuration file into the repository's hardware directory:

```
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hardware/<newhost>-hw-config.nix
```

Replace <newhost> with a short, lowercase hostname (for example: thinkpad, workstation, server1).

Commit this file to the repository.

## 3. Create Host Hardware Configuration Files

The repository uses a structured hardware directory. For each new host, you need to create:

### 3.1. Hardware-specific files

Create the following files in the `hardware/` directory:

1. **hardware/<newhost>-hw-config.nix** - The generated hardware configuration from NixOS
2. **hardware/<newhost>.nix** - Host-specific hardware settings (GPU, Wi-Fi, etc.)
3. **hardware/performance/<newhost>.nix** - Performance tuning specific to this machine

You can copy existing examples:

```bash
# Copy and adapt hardware config (already done in step 2)
# Now create the hardware-specific module
cp hardware/macbook.nix hardware/<newhost>.nix

# Create performance tuning module
cp hardware/performance/macbook.nix hardware/performance/<newhost>.nix
```

Edit these files to match your hardware (GPU drivers, Wi-Fi, power management, etc.).

## 4. Create a New Host Definition

Create a new host file:

```
nixos-config/hosts/<newhost>.nix
```

The easiest path is to copy an existing host and adjust it:

```
cp nixos-config/hosts/macbook.nix nixos-config/hosts/<newhost>.nix
```

Edit hosts/<newhost>.nix and adjust the following:

### Required changes

- Hostname:
```nix
  networking.hostName = "<newhost>-nixos";
```

- Imports

  Update the hardware imports to match your new host:

```nix
  imports = [
    ../hardware/<newhost>.nix
    ../hardware/performance/<newhost>.nix
    ../hardware/<newhost>-hw-config.nix
    # Add desktop environment modules as needed
    ../modules/desktops/gnome.nix
  ];
```

  Keep only the hardware and performance modules that make sense for this machine.

### Optional changes

- Bootloader (EFI vs Legacy BIOS)
  ```nix
  # For EFI systems (modern machines)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # For Legacy BIOS (older machines)
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];
  ```

- GPU or Wi-Fi drivers (configure in hardware/<newhost>.nix)
- Power and performance tuning (configure in hardware/performance/<newhost>.nix)
- Desktop environment selection (import appropriate modules from modules/desktops/)
- Keyboard layout and console settings

## 5. Register the Host in flake.nix

Edit flake.nix and add a new entry under nixosConfigurations using the mkHost helper function.

The current flake uses a simplified helper function. Add your host like this (replace `newhost` with your actual hostname):

```nix
nixosConfigurations = {
  macbook = mkHost { hostname = "macbook"; system = "x86_64-linux"; };
  dell = mkHost { hostname = "dell"; system = "x86_64-linux"; };
  newhost = mkHost { hostname = "newhost"; system = "x86_64-linux"; };
};
```

For ARM-based systems (like Apple Silicon or Raspberry Pi), use:
```nix
  newhost = mkHost { hostname = "newhost"; system = "aarch64-linux"; };
```

The mkHost function automatically:
- Applies the unstable overlay
- Imports core.nix (shared configuration)
- Imports your host file from ./hosts/<newhost>.nix
- Integrates Catppuccin theme
- Configures home-manager for the "borba" user
- Passes feature flags (devopsEnabled, qemuEnabled)

This makes the host selectable via the flake.

## 6. Build the System on the New Machine

Clone the repository on the new machine:

```
git clone https://github.com/waldirborbajr/nixos-config.git
cd nixos-config
```

Build and switch to the new host:

```
make switch HOST=<newhost>
```

Optional modes:

```
make switch HOST=<newhost> DEVOPS=1  
make switch HOST=<newhost> QEMU=1  
make switch HOST=<newhost> DEVOPS=1 QEMU=1
```

## Summary Checklist

To add a new host, you need to:

1. Copy hardware-configuration.nix to hardware/<newhost>-hw-config.nix
2. Create hardware/<newhost>.nix (hardware-specific settings)
3. Create hardware/performance/<newhost>.nix (performance tuning)
4. Create hosts/<newhost>.nix (host configuration)
5. Register the host in flake.nix using mkHost
6. Run make switch HOST=<newhost>

Everything else (core modules, home-manager, themes) is reused automatically.

## Design Philosophy

- Core logic is shared via core.nix
- Hardware is isolated in hardware/ directory with modular structure
- Performance tuning separated in hardware/performance/
- Features (DEVOPS and QEMU) are opt-in via environment variables
- Home-Manager integrated for per-user configuration
- Catppuccin theme system-wide
- Fully reproducible across machines

If a machine fails, reinstalling it takes minutes, not days.
