# NixOS Installation Guide (From Scratch)

This document describes the recommended procedure to install NixOS on a brand-new machine,
clone this repository, and build the system without relying on preinstalled tools such as
git, make, or editors on the final system.

The process is intentionally split into phases.

---

## PHASE 1 — Minimal NixOS Installation (Live ISO)

Boot using the official NixOS Installer ISO.

### 1. Partition, format, and mount disks

Adjust disk names as needed.

Command example:

```
mount /dev/disk/by-label/nixos /mnt
```

If you have separate partitions:

```
mount /dev/disk/by-label/boot /mnt/boot  
mount /dev/disk/by-label/home /mnt/home
```

---

### 2. Generate hardware configuration

Run:

```
nixos-generate-config --root /mnt
```

This generates:

```
/mnt/etc/nixos/configuration.nix  
/mnt/etc/nixos/hardware-configuration.nix
```

---

### 3. Enable networking

Edit `/mnt/etc/nixos/configuration.nix` and ensure:

- NetworkManager is enabled
- SSH is enabled (optional but recommended)

---

### 4. Install NixOS

Run:

```
nixos-install
```

Then reboot.

---

## PHASE 2 — Clone the Repository (Using Live ISO)

This phase is executed before rebooting, or by booting again into the Live ISO.

The Live ISO already includes git, curl, and basic editors.

### 1. Create the future home directory

```
mkdir -p /mnt/home/borba  
chown 1000:100 /mnt/home/borba
```

Adjust the username if needed.

---

### 2. Clone the repository into the installed system

```
git clone https://github.com/YOUR_USER/nixos-config /mnt/home/borba/nixos-config
```

---

### 3. Replace /etc/nixos with your repository

```
rm -rf /mnt/etc/nixos  
ln -s /mnt/home/borba/nixos-config /mnt/etc/nixos
```

---

### 4. Reinstall using your configuration

```
nixos-install --root /mnt
```

Then reboot into the installed system.

---

## PHASE 3 — First Boot

After rebooting into the new system:

- The system is expected to be minimal
- Tools like git, make, and editors should come from Nix

Apply your full configuration:

```
sudo nixos-rebuild switch
```

---

## ALTERNATIVE — No Git Required

If git is not available or not desired.

### 1. Download repository as tarball

```
curl -L https://github.com/YOUR_USER/nixos-config/archive/refs/heads/main.tar.gz | tar xz -C /mnt/home/borba
```

### 2. Rename directory

```
mv /mnt/home/borba/nixos-config-main /mnt/home/borba/nixos-config
```

Then continue from PHASE 2.

---

## KEY PRINCIPLE

A fresh NixOS installation is expected to be minimal.

You should rely on:

- nixos-install
- nixos-rebuild
- declarative configuration

Avoid manual package installation.

---

## SUMMARY

Install OS with nixos-install  
Fetch configuration using Live ISO tools  
Build system with nixos-rebuild  
All tools are declared in Nix

This file is intentionally self-contained.
