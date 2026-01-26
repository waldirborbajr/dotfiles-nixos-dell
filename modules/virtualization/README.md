# Virtualization & Containers Guide

## Overview

This directory manages all virtualization and container runtime services:
- **Docker** - Traditional container runtime
- **Podman** - Modern Docker alternative (rootless by default)
- **K3s** - Lightweight Kubernetes cluster
- **Libvirt** - QEMU/KVM virtual machines

## ⚠️ Important Rules

### Container Runtimes (Docker vs Podman)

**NEVER enable Docker and Podman simultaneously!** They conflict with each other.

Current setup:
- ✅ **Docker** - ENABLED (default during migration)
- ❌ **Podman** - DISABLED (commented out)

### How to Switch from Docker to Podman

1. Edit [`modules/virtualization/default.nix`](default.nix):

```nix
# Comment out Docker
# ./docker.nix

# Uncomment Podman
./podman.nix
```

2. Rebuild your system:

```bash
sudo nixos-rebuild switch --flake .#hostname
```

3. Verify:

```bash
# For Podman (with Docker compatibility)
docker --version  # Should show "podman version ..."
podman --version

# Check service status
systemctl status podman.socket
```

### How to Enable/Disable Services

All services are **disabled by default** except Docker.

#### Enable K3s (Kubernetes)

Edit [`modules/virtualization/default.nix`](default.nix):

```nix
# Uncomment K3s
./k3s.nix
```

Or override in your host config:

```nix
services.k3s.enable = true;
```

#### Enable Libvirt (QEMU/KVM VMs)

Edit [`modules/virtualization/default.nix`](default.nix):

```nix
# Uncomment Libvirt
./libvirt.nix
```

Or override in your host config:

```nix
virtualisation.libvirtd.enable = true;
```

### QEMU via features/qemu.nix

For temporary VM usage, use the `QEMU=1` flag:

```bash
# Enable QEMU for this build
QEMU=1 sudo nixos-rebuild switch --flake .#hostname --impure
```

This loads full QEMU tooling without permanently enabling it.

## Service Status Reference

| Service | Default State | Enable Method | Disable Method |
|---------|---------------|---------------|----------------|
| **Docker** | ✅ Enabled | Imported in default.nix | Comment out import |
| **Podman** | ❌ Disabled | Uncomment in default.nix | Comment out import |
| **K3s** | ❌ Disabled | Uncomment in default.nix | Comment out import |
| **Libvirt** | ❌ Disabled | Uncomment in default.nix | Comment out import |
| **QEMU (temp)** | ❌ Disabled | `QEMU=1` flag | Remove flag |

## Configuration Files

- [`default.nix`](default.nix) - Central management (edit imports here)
- [`docker.nix`](docker.nix) - Docker configuration
- [`podman.nix`](podman.nix) - Podman configuration
- [`k3s.nix`](k3s.nix) - K3s configuration
- [`libvirt.nix`](libvirt.nix) - Libvirt/QEMU configuration

## Per-Host Overrides

You can disable services per host in `hosts/*.nix`:

```nix
# hosts/dell.nix - Disable all virtualization on slow machine
virtualisation.docker.enable = lib.mkForce false;
services.k3s.enable = lib.mkForce false;
virtualisation.libvirtd.enable = lib.mkForce false;
```

## Safety Features

The system includes an assertion that prevents Docker and Podman from being enabled simultaneously:

```nix
assertion = !(config.virtualisation.docker.enable && config.virtualisation.podman.enable);
```

If both are enabled, you'll get a clear error message during build.

## Migration Checklist

When migrating from Docker to Podman:

- [ ] Test your containers with Podman first
- [ ] Update docker-compose files if needed
- [ ] Switch import in `default.nix`
- [ ] Rebuild system
- [ ] Verify `docker` alias points to `podman`
- [ ] Test all workflows
- [ ] Remove old Docker data: `sudo rm -rf /var/lib/docker` (optional)

## Troubleshooting

### Both runtimes accidentally enabled

```bash
# Check current status
systemctl status docker
systemctl status podman

# Force disable one in your host config
virtualisation.docker.enable = lib.mkForce false;
```

### Podman rootless not working

Ensure your user has lingering enabled:

```bash
loginctl enable-linger $USER
```

This is automatically configured in `podman.nix`.

### QEMU/Libvirt permission issues

Ensure your user is in the required groups:

```bash
groups | grep -E 'libvirtd|kvm'
```

This is automatically configured in `libvirt.nix`.
