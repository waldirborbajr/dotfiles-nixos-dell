# Dendritic Pattern for NixOS Configurations

## What is the Dendritic Pattern?

The **Dendritic Pattern** is an architectural approach for organizing NixOS configurations inspired by neural dendrites - the branching structures that receive and process signals in neurons.

Just as dendrites form a hierarchical tree from cell body to synapses, the Dendritic Pattern organizes configuration from a root (flake) through branches (profiles) to terminal modules (leaves), with explicit activation at each connection point.

## Core Principles

### 1. Hierarchical Tree Structure

Configuration flows in one direction through well-defined layers:

```
Root (flake.nix)
  ↓
Minimal Core (core.nix)
  ↓
Profiles Layer (profiles/)
  ↓
Modules Layer (modules/)
  ↓
Host Composition (hosts/)
```

### 2. Option-Based Activation

Every module uses explicit options for activation:

```nix
# Module definition
{ config, lib, ... }:
{
  config = lib.mkIf config.category.module.enable {
    # Configuration only active when enabled
  };
}

# Activation
category.module.enable = true;
```

### 3. Aggregator Pattern

Each category has a `default.nix` that:
- Imports all submodules
- Defines options for each
- Acts as a catalog/index

```nix
# modules/apps/default.nix
{
  imports = [
    ./shell.nix
    ./terminals.nix
    ./dev-tools.nix
  ];
  
  options.apps = {
    shell.enable = mkOption { ... };
    terminals.enable = mkOption { ... };
    dev-tools.enable = mkOption { ... };
  };
}
```

### 4. Profile Composition

Profiles compose modules into reusable groups:

```nix
# profiles/minimal.nix - Base system
{
  imports = [ ../modules/system ];
  system-config.base.enable = true;
}

# profiles/desktop.nix - GUI capabilities
{
  imports = [ ./minimal.nix ];
  # Desktop modules enabled per-host
}

# profiles/developer.nix - Development tools
{
  imports = [ ./desktop.nix ../modules/virtualization ];
  # Virtualization available
}
```

### 5. Clear Layer Boundaries

Each layer has distinct responsibilities:

| Layer | Responsibility | Uses Options? |
|-------|---------------|---------------|
| Root (flake) | Define inputs, create hosts | No (root) |
| Core | Essential imports only | No (minimal) |
| Profiles | Compose modules | No (compose) |
| Modules | Actual configuration | Yes (leaves) |
| Hosts | Final composition | No (compose) |

## Architecture Diagram

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ flake.nix (Root Neuron)                         ┃
┃  • Define inputs                                 ┃
┃  • Create mkHost function                        ┃
┃  • Generate nixosConfigurations                  ┃
┗━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
             ├─→ core.nix (Cell Body)
             │    └─→ Minimal essentials
             │
             ├─→ profiles/ (Primary Dendrites)
             │    ├─→ minimal.nix
             │    │    └─→ modules/system/ ←─┐
             │    │    └─→ modules/users/  ←─┤
             │    │                           │
             │    ├─→ desktop.nix             │ Option-based
             │    │    └─→ inherits minimal   │ activation
             │    │                           │ (Synapses)
             │    └─→ developer.nix           │
             │         └─→ inherits desktop   │
             │         └─→ modules/virt/   ←─┘
             │
             ├─→ modules/ (Terminal Dendrites)
             │    ├─→ system/default.nix (Aggregator)
             │    │    ├─→ base.nix
             │    │    ├─→ networking.nix
             │    │    └─→ audio.nix
             │    │
             │    ├─→ apps/default.nix (Aggregator)
             │    │    ├─→ shell.nix
             │    │    ├─→ terminals.nix
             │    │    └─→ dev-tools.nix
             │    │
             │    └─→ languages/default.nix (Aggregator)
             │         ├─→ go.nix
             │         ├─→ rust.nix
             │         └─→ nix-dev.nix
             │
             └─→ hosts/ (Axon Terminals - Output)
                  ├─→ dell.nix
                  │    └─→ Uses: desktop profile + i3
                  │
                  └─→ macbook.nix
                       └─→ Uses: developer profile + gnome/niri
```

## Pattern Benefits

### 1. Self-Documenting

Options show available features:
```nix
# What can I enable?
options.apps = {
  shell.enable = ...;      # ZSH + FZF + bat
  terminals.enable = ...;  # Alacritty
  dev-tools.enable = ...;  # Git + GitHub CLI
  # ...
};
```

### 2. Composable

Build complex configs from simple parts:
```nix
# Start small
imports = [ ./profiles/minimal.nix ];

# Add GUI
imports = [ ./profiles/desktop.nix ];  # includes minimal

# Add dev tools
imports = [ ./profiles/developer.nix ];  # includes desktop + minimal
```

### 3. Testable

Toggle features easily:
```nix
# Disable to test
apps.yazi.enable = false;

# Re-enable
apps.yazi.enable = true;
```

### 4. Maintainable

Changes are isolated:
```
modules/apps/shell.nix      # Only shell config
modules/apps/default.nix    # Only shell option
home.nix                    # Only shell activation
```

### 5. Scalable

Adding features is simple:

```nix
# 1. Create module
modules/apps/newtool.nix

# 2. Add option
modules/apps/default.nix → options.apps.newtool.enable

# 3. Activate
home.nix → apps.newtool.enable = true
```

## Implementation Guidelines

### Module Template

```nix
# modules/category/module.nix
{ config, lib, pkgs, ... }:

{
  # Option defined in default.nix aggregator
  
  config = lib.mkIf config.category.module.enable {
    # Your configuration here
    environment.systemPackages = [ pkgs.something ];
    services.something.enable = true;
    
    # More config...
  };
}
```

### Aggregator Template

```nix
# modules/category/default.nix
{ config, lib, ... }:

{
  imports = [
    ./module1.nix
    ./module2.nix
    ./module3.nix
  ];

  options.category = {
    module1.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable module1";
    };
    
    module2.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable module2";
    };
    
    # ... more options
  };
}
```

### Profile Template

```nix
# profiles/myprofile.nix
{ config, lib, ... }:

{
  imports = [
    # Inherit from other profiles
    ./base-profile.nix
    
    # Import modules
    ../modules/category
  ];

  # Enable modules via options
  category = {
    module1.enable = true;
    module2.enable = true;
  };
  
  # Other settings...
}
```

### Host Template

```nix
# hosts/myhost.nix
{
  imports = [
    # Hardware
    ../hardware/myhost.nix
    ../hardware/myhost-hw-config.nix
    
    # Profile
    ../profiles/myprofile.nix
    
    # Desktop (if needed)
    ../modules/desktops/mydesktop.nix
  ];

  # Host-specific settings
  networking.hostName = "myhost";
  system.stateVersion = "25.11";
  
  # Override profile defaults if needed
  category.module.enable = false;
}
```

## Best Practices

### DO:

✅ **Use options for all modules**
```nix
config = lib.mkIf config.apps.zsh.enable { ... };
```

✅ **Create aggregators for categories**
```nix
modules/apps/default.nix  # Defines options.apps.*
```

✅ **Compose profiles from profiles**
```nix
imports = [ ./minimal.nix ];  # Inherit lower profile
```

✅ **Keep core.nix minimal**
```nix
# Only absolute essentials (themes, features)
```

✅ **Document options**
```nix
description = "Enable shell configuration (ZSH + FZF + bat)";
```

✅ **Test incrementally**
```nix
# Toggle one module at a time
apps.shell.enable = false;  # Test without shell
```

### DON'T:

❌ **Force imports without options**
```nix
# Bad: Always active
imports = [ ./module.nix ];

# Good: Option-controlled
imports = [ ./module.nix ];
config = lib.mkIf config.module.enable { ... };
```

❌ **Put logic in core.nix**
```nix
# Bad: core.nix has services
services.something.enable = true;

# Good: core.nix only imports
imports = [ ./modules/themes ];
```

❌ **Duplicate config in profiles**
```nix
# Bad: Repeat config in each profile
profiles/desktop.nix → system-config.base.enable = true
profiles/minimal.nix → system-config.base.enable = true

# Good: Set in minimal, inherit in desktop
profiles/minimal.nix → system-config.base.enable = true
profiles/desktop.nix → imports = [ ./minimal.nix ];
```

❌ **Skip aggregators**
```nix
# Bad: Options scattered everywhere
modules/apps/zsh.nix → options.apps.zsh.enable
modules/apps/tmux.nix → options.apps.tmux.enable

# Good: Centralized in aggregator
modules/apps/default.nix → options.apps = { shell, tmux, ... }
```

## Comparison with Other Patterns

| Pattern | Structure | Activation | Reusability | Complexity |
|---------|-----------|------------|-------------|------------|
| **Monolithic** | Single file | Always on | None | Low |
| **Modular** | Separate files | Import-based | Manual | Medium |
| **Dendritic** | Tree hierarchy | Option-based | Profile composition | Medium |

### Migration Path

**From Monolithic:**
```nix
# Before: One big file
{ config, pkgs, ... }: {
  # Everything here
}

# After: Dendritic
imports = [ ./profiles/desktop.nix ];
apps.zsh.enable = true;
```

**From Modular:**
```nix
# Before: Direct imports
imports = [
  ./modules/zsh.nix
  ./modules/terminal.nix
];

# After: Dendritic with options
imports = [ ./modules/apps ];
apps = {
  shell.enable = true;
  terminals.enable = true;
};
```

## Real-World Example

This repository demonstrates a complete Dendritic Pattern implementation:

```
waldirborbajr/nixos-config
├── flake.nix                    # Root
├── core.nix                     # Minimal core
├── profiles/                    # Composition layer
│   ├── minimal.nix
│   ├── desktop.nix
│   └── developer.nix
├── modules/                     # Terminal modules
│   ├── system/default.nix       # Aggregator + options
│   ├── apps/default.nix         # Aggregator + options
│   └── languages/default.nix    # Aggregator + options
└── hosts/                       # Final composition
    ├── dell.nix     → desktop profile
    └── macbook.nix  → developer profile
```

**Result:** ~95% alignment with NixOS module system best practices.

## Further Resources

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Full architecture documentation
- [README.md](./README.md) - Repository overview
- [NixOS Module System Manual](https://nixos.org/manual/nixos/stable/#sec-writing-modules)

---

**Pattern Version:** 1.0  
**Implementation:** waldirborbajr/nixos-config  
**Date:** 2026-01-29
