# Quick Start - SOPS Secrets Management

This is a quick reference guide. See [SECRETS-MANAGEMENT.md](./SECRETS-MANAGEMENT.md) for complete documentation.

## First Time Setup (5 minutes)

### 1. Generate Age Key

```bash
# Install tools
nix-shell -p age sops ssh-to-age

# Generate age key from your SSH key
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Get your public key
ssh-to-age < ~/.ssh/id_ed25519.pub
# Copy the output (age1...)
```

### 2. Create .sops.yaml

```bash
# Copy template
cp .sops.yaml.example .sops.yaml

# Edit and replace with YOUR public key from step 1
nvim .sops.yaml
```

### 3. Add sops-nix to flake

Edit `flake.nix`:

```nix
inputs = {
  # ... existing inputs
  sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

outputs = { self, nixpkgs, home-manager, sops-nix, ... }: {
  nixosConfigurations.macbook-nixos = nixpkgs.lib.nixosSystem {
    modules = [
      ./hosts/macbook.nix
      sops-nix.nixosModules.sops  # Add this
    ];
  };
};
```

### 4. Enable secrets module

Edit your host file (e.g., `hosts/macbook.nix`):

```nix
{
  imports = [
    # ... existing imports
    ../modules/system/secrets.nix
  ];
  
  # Enable secrets management
  system-config.secrets.enable = true;
}
```

### 5. Create your first secret

```bash
# Create encrypted secrets file
sops secrets/common/secrets.yaml
```

Add your SSH key:

```yaml
ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  your-private-key-content-here
  -----END OPENSSH PRIVATE KEY-----

ssh_public_key: ssh-ed25519 AAAAC3... user@host
```

Save and exit (Ctrl+O, Enter, Ctrl+X).

### 6. Configure secret deployment

Edit `modules/system/secrets.nix`:

```nix
config = lib.mkIf config.system-config.secrets.enable {
  sops = {
    defaultSopsFile = ../../secrets/common/secrets.yaml;
    age.keyFile = "/home/borba/.config/sops/age/keys.txt";
    
    secrets = {
      ssh_private_key = {
        owner = "borba";
        path = "/home/borba/.ssh/id_ed25519";
        mode = "0600";
      };
      
      ssh_public_key = {
        owner = "borba";
        path = "/home/borba/.ssh/id_ed25519.pub";
        mode = "0644";
      };
    };
  };
};
```

### 7. Rebuild

```bash
# Update flake lock
nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#macbook-nixos

# Verify SSH key is deployed
ls -la ~/.ssh/id_ed25519
ssh -T git@github.com
```

## Daily Usage

### Edit secrets

```bash
sops secrets/common/secrets.yaml
```

### View secrets (decrypted)

```bash
sops -d secrets/common/secrets.yaml
```

### Add new secret

```bash
# 1. Edit secrets file
sops secrets/common/secrets.yaml

# 2. Add new key-value pair
new_secret: my_secret_value

# 3. Configure in NixOS (modules/system/secrets.nix)
sops.secrets.new_secret = {
  owner = "borba";
  mode = "0600";
};

# 4. Rebuild
sudo nixos-rebuild switch --flake .#macbook-nixos

# 5. Secret available at:
cat /run/secrets/new_secret
```

### Verify encryption before commit

```bash
# Check file is encrypted
cat secrets/common/secrets.yaml
# Should show encrypted binary data with "sops" markers

# If you see plaintext, DON'T COMMIT!
```

## Common Commands

```bash
# Edit secret
sops secrets/common/secrets.yaml

# View decrypted
sops -d secrets/common/secrets.yaml

# Re-encrypt with new key
sops updatekeys secrets/common/secrets.yaml

# Check which key was used
sops -d --extract '["sops"]["age"]' secrets/common/secrets.yaml
```

## Safety Checklist

Before every commit:

- [ ] `.sops.yaml` not in Git (use `.sops.yaml.example`)
- [ ] `keys.txt` not in Git
- [ ] Secrets files are encrypted (binary, not plaintext)
- [ ] No hardcoded secrets in `.nix` files

## Troubleshooting

### "failed to get the data key"

```bash
# Verify key exists
ls ~/.config/sops/age/keys.txt

# Verify public key matches
age-keygen -y ~/.config/sops/age/keys.txt
# Compare with .sops.yaml

# Re-encrypt
sops updatekeys secrets/common/secrets.yaml
```

### "Permission denied"

```bash
# Fix ownership
sudo chown borba:users /run/secrets/secret_name
sudo chmod 600 /run/secrets/secret_name
```

### Secrets not updating

```bash
# Clear and rebuild
sudo rm -rf /run/secrets/*
sudo nixos-rebuild switch --flake .#macbook-nixos
```

## Next Steps

Read the complete documentation: [SECRETS-MANAGEMENT.md](./SECRETS-MANAGEMENT.md)

- Host-specific secrets
- Multiple secrets files
- Binary secrets
- Templates and placeholders
- Key rotation
- Best practices
