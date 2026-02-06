# DevContainer Configuration

This configuration allows you to develop and test the NixOS configuration in a GitHub Codespace or another DevContainer environment.

## 🎯 What it includes

- **Nix with Flakes** enabled
- **Git** and **GitHub CLI**
- **direnv** for auto-activation of devshells
- **VS Code extensions** for Nix development

## 🚀 Using on GitHub Codespaces

1. Open the repository on GitHub
2. Click **Code** → **Codespaces** → **Create codespace on REFACTORv2**
3. Wait for the container to be created (first run may take ~5 min)
4. Nix will be installed automatically via the setup script

## 💻 Available commands

### List available devshells
```bash
nix flake show
```

### Activate a devshell
```bash
# Rust
nix develop .#rust

# Go
nix develop .#go

# PostgreSQL
nix develop .#postgresql

# All databases
nix develop .#databases
```

### Use direnv (auto-activation)
```bash
# In the project directory
echo "use flake .#rust" > .envrc
direnv allow

# Now the shell is activated automatically when you enter the directory!
```

## 🛠️ Testing configurations

```bash
# Check flake syntax
nix flake check

# Show metadata
nix flake metadata

# Evaluate a configuration
nix eval .#nixosConfigurations.dell.config.system.stateVersion
```

## 🔄 Updating the DevContainer

If you modify `.devcontainer/devcontainer.json`:

1. **In VS Code**: Command Palette → "Rebuild Container"
2. **In Codespace**: Recreate the Codespace

## 📝 Notes

- Nix is installed in **single-user** mode (no root required)
- Flakes are enabled by default
- Build cache is local to the container (does not persist between rebuilds)
- For persistence, use volumes or GitHub Codespaces prebuilds

## 🐛 Troubleshooting

### `nix` command not found after setup

```bash
# Reload the shell
source ~/.bashrc

# Or check if Nix is on PATH
echo $PATH | grep nix
```

### Experimental features error

```bash
# Add to your configuration
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### DevShell not found

```bash
# Update flake inputs
nix flake update

# Clear the cache
nix flake lock --update-input nixpkgs-stable
```
