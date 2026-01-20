# OPERATIONS.md

# Day-2 Operations Guide

This document describes day-2 operational tasks for this NixOS system.
It focuses on maintenance, upgrades, recovery, and diagnostics.

All operations assume the repository lives at:

$HOME/nixos-config

---

## Core Rule

Never edit the running system directly.

All changes must be made in the repository and applied via rebuild.

---

## Common Operations

### Rebuild and Switch

Apply current configuration:

make switch

Build without switching:

make build

Rollback to previous generation:

make rollback

---

## System Updates

### Update Nix Channels

Update channels (including unstable):

make channels

Then rebuild:

make switch

---

## Garbage Collection

### Soft Cleanup

Remove old generations older than 7 days:

make gc-soft

### Hard Cleanup

Aggressive cleanup:

make gc-hard

Use hard GC only when disk space is critically low.

---

## Store Maintenance

### Optimize Store

Deduplicate store paths:

make optimise

### Verify Store Integrity

Check for corruption:

make verify

---

## Disk Space Management

Check disk usage:

make space

Inspect store size:

du -sh /nix/store

List generations:

make generations

Delete old generations manually if required:

sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

---

## Diagnostics

Run system diagnostics:

make doctor

Doctor checks:
- Nix availability
- Active system generation
- GC timers
- Docker and K3s status
- Store size

---

## Container Operations

### Docker

Check status:

systemctl status docker

Restart Docker:

sudo systemctl restart docker

### Podman

Ensure Docker is disabled before enabling Podman.

Switch requires editing configuration and rebuilding.

### K3s

Check status:

systemctl status k3s

Kubeconfig location:

/etc/rancher/k3s/k3s.yaml

---

## Virtualization

Check libvirt:

systemctl status libvirtd

User must belong to libvirtd group.

virt-manager is the primary GUI.

---

## Kernel and Boot Issues

List available generations:

sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

Reboot into an older generation via boot menu if system does not start.

---

## Recovery Procedure

If the system fails to boot:

1. Select a previous generation in the bootloader
2. Boot successfully
3. Fix configuration in repo
4. Run make switch

If the system is completely broken:

1. Boot from NixOS installer
2. Mount disks
3. Chroot if necessary
4. Clone repo
5. Rebuild system

---

## Adding New Software

Never install software imperatively.

Do not use:
- nix-env -i
- nix profile install

Always:
- Edit modules/system-packages.nix
- Rebuild

---

## Removing Software

Remove packages from system-packages.nix.
Rebuild.
Run garbage collection if needed.

---

## Hardware Changes

When moving to new hardware:

1. Generate new hardware-configuration.nix
2. Create or adjust hardware module
3. Select appropriate profile
4. Rebuild

---

## Backups

This repository is the backup.

Ensure it is:
- Committed
- Pushed
- Versioned

Optional:
- Back up /home separately

---

## Operational Philosophy

- Rebuilds are cheap
- Rollbacks are safe
- State is disposable
- Configuration is the source of truth

If a fix cannot be expressed declaratively, it is not acceptable.

---

Version: v1.0
