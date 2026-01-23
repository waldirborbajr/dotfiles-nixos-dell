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

On the new machine, copy the hardware configuration file into the repository:

```
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hardware-configuration-<newhost>.nix
```

Replace <newhost> with a short, lowercase hostname (for example: thinkpad, workstation, server1).

Commit this file to the repository.

## 3. Create a New Host Definition

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
```
  networking.hostName = "<newhost>-nixos";
```

- Imports

  Replace the hardware import with:

```
  ../hardware-configuration-<newhost>.nix
```

  Keep only the hardware and performance modules that make sense for this machine.

### Optional changes

- GPU or Wi-Fi drivers
- Power and performance tuning
- Desktop environment selection
- Default DEVOPS or QEMU behavior

## 4. Register the Host in flake.nix

Edit flake.nix and add a new entry under nixosConfigurations.

Copy an existing block and adapt it:

```
<newhost> = nixpkgs-stable.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit devopsEnabled qemuEnabled;
  };

  modules = [
    ({ ... }: { nixpkgs.overlays = [ unstableOverlay ]; })
    ./core.nix
    ./hosts/<newhost>.nix
  ];
};
```

This makes the host selectable via the flake.

## 5. Build the System on the New Machine

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

To add a new host, you only need to:

- Copy hardware-configuration.nix
- Create hosts/<newhost>.nix
- Register the host in flake.nix
- Run make switch HOST=<newhost>

Everything else is reused automatically.

## Design Philosophy

- Core logic is shared
- Hardware is isolated
- Features (DEVOPS and QEMU) are opt-in
- No Home-Manager dependency
- Fully reproducible across machines

If a machine fails, reinstalling it takes minutes, not days.
