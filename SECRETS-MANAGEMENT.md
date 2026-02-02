# Secrets Management with sops-nix

This guide explains how to securely manage secrets (SSH keys, API tokens, passwords) in your NixOS configuration using **sops-nix**.

## Table of Contents

- [What is sops-nix?](#what-is-sops-nix)
- [Initial Setup](#initial-setup)
- [Basic Usage](#basic-usage)
- [SSH Key Management](#ssh-key-management)
- [Advanced Configuration](#advanced-configuration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## What is sops-nix?

**sops-nix** is a NixOS module that integrates [SOPS (Secrets OPerationS)](https://github.com/getsops/sops) into your configuration. It allows you to:

- ✅ Encrypt secrets and commit them to Git
- ✅ Decrypt secrets automatically during system activation
- ✅ Use age or GPG for encryption
- ✅ Share secrets across multiple machines
- ✅ Rotate encryption keys safely

## Initial Setup

### 1. Add sops-nix to flake inputs

Edit `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    
    # Add sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }: {
    nixosConfigurations = {
      macbook-nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/macbook.nix
          sops-nix.nixosModules.sops  # Add this
        ];
      };
    };
  };
}
```

### 2. Generate age key

Age is the recommended encryption method for sops-nix.

```bash
# Install age
nix-shell -p age

# Generate age key from existing SSH key
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Get public key for .sops.yaml
ssh-to-age < ~/.ssh/id_ed25519.pub
# Output: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
```

If you don't have an SSH key yet:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

### 3. Create .sops.yaml configuration

Create `.sops.yaml` in your repository root:

```yaml
# .sops.yaml - SOPS configuration file
keys:
  # Replace with YOUR age public key from step 2
  - &admin_borba age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p

creation_rules:
  # Default: encrypt everything with admin key
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
    - age:
      - *admin_borba
  
  # Host-specific secrets
  - path_regex: secrets/macbook/[^/]+\.yaml$
    key_groups:
    - age:
      - *admin_borba
  
  - path_regex: secrets/dell/[^/]+\.yaml$
    key_groups:
    - age:
      - *admin_borba
```

### 4. Create secrets directory structure

```bash
mkdir -p secrets/{common,macbook,dell}
```

## Basic Usage

### Creating and Editing Secrets

#### 1. Create a new secrets file

```bash
# Install sops
nix-shell -p sops

# Create and edit secrets file
sops secrets/common/secrets.yaml
```

SOPS will open your editor with a template:

```yaml
# secrets/common/secrets.yaml
ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  your-ssh-private-key-here
  -----END OPENSSH PRIVATE KEY-----

github_token: ghp_your_token_here

tailscale_auth_key: tskey-auth-your-key-here

example_password: my_secure_password
```

Save and exit. The file will be encrypted automatically.

#### 2. Edit existing secrets

```bash
sops secrets/common/secrets.yaml
```

#### 3. View secrets (decrypted)

```bash
sops -d secrets/common/secrets.yaml
```

### Using Secrets in NixOS

Create a secrets module:

```nix
# modules/system/secrets.nix
{ config, lib, ... }:

{
  # Configure sops
  sops = {
    # Default secrets file
    defaultSopsFile = ../../secrets/common/secrets.yaml;
    
    # Where to find age key for decryption
    age.keyFile = "/home/borba/.config/sops/age/keys.txt";
    
    # Define secrets
    secrets = {
      # SSH private key
      ssh_private_key = {
        owner = "borba";
        path = "/home/borba/.ssh/id_ed25519";
        mode = "0600";
      };
      
      # GitHub token
      github_token = {
        owner = "borba";
        mode = "0600";
      };
      
      # Tailscale auth key
      tailscale_auth_key = {
        mode = "0600";
      };
    };
  };
  
  # Secrets are available at:
  # /run/secrets/ssh_private_key
  # /run/secrets/github_token
  # /run/secrets/tailscale_auth_key
  
  # Or at custom paths if specified (like SSH key above)
}
```

Import in your configuration:

```nix
# hosts/macbook.nix
{
  imports = [
    ../modules/system/secrets.nix
  ];
}
```

## SSH Key Management

### Complete SSH Key Setup

#### 1. Create secrets file with SSH key

```bash
# Generate new SSH key if needed
ssh-keygen -t ed25519 -f /tmp/id_ed25519 -C "wborbajr@gmail.com"

# Create secrets file
sops secrets/common/ssh-keys.yaml
```

Add your SSH private key:

```yaml
# secrets/common/ssh-keys.yaml
ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
  ... (your full private key here) ...
  -----END OPENSSH PRIVATE KEY-----

ssh_public_key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... wborbajr@gmail.com
```

#### 2. Configure SSH key deployment

```nix
# modules/system/secrets.nix
{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/common/ssh-keys.yaml;
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
  
  # Ensure SSH directory exists
  system.activationScripts.setupSSH = ''
    mkdir -p /home/borba/.ssh
    chown borba:users /home/borba/.ssh
    chmod 700 /home/borba/.ssh
  '';
}
```

#### 3. Rebuild and verify

```bash
sudo nixos-rebuild switch --flake .#macbook-nixos

# Verify SSH key is deployed
ls -la ~/.ssh/
cat ~/.ssh/id_ed25519.pub

# Test SSH key
ssh -T git@github.com
```

### GitHub CLI Authentication

Store GitHub token securely:

```yaml
# secrets/common/github.yaml
github_token: ghp_your_personal_access_token_here
```

Use in configuration:

```nix
# modules/apps/dev-tools.nix
{ config, lib, ... }:

{
  sops.secrets.github_token = {
    owner = "borba";
    mode = "0600";
  };
  
  # Set GH_TOKEN environment variable
  home.sessionVariables = {
    GH_TOKEN = "$(cat ${config.sops.secrets.github_token.path})";
  };
}
```

## Advanced Configuration

### Host-Specific Secrets

Different secrets per machine:

```yaml
# .sops.yaml
keys:
  - &admin age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
  - &macbook age1macbookpublickeyhere
  - &dell age1dellpublickeyhere

creation_rules:
  - path_regex: secrets/macbook/.*
    key_groups:
    - age:
      - *admin
      - *macbook
  
  - path_regex: secrets/dell/.*
    key_groups:
    - age:
      - *admin
      - *dell
```

```nix
# hosts/macbook.nix
{
  sops.defaultSopsFile = ../../secrets/macbook/secrets.yaml;
}

# hosts/dell.nix
{
  sops.defaultSopsFile = ../../secrets/dell/secrets.yaml;
}
```

### Multiple Secrets Files

```nix
sops.secrets = {
  ssh_key = {
    sopsFile = ../../secrets/common/ssh-keys.yaml;
    owner = "borba";
  };
  
  api_tokens = {
    sopsFile = ../../secrets/common/api-tokens.yaml;
    owner = "borba";
  };
  
  db_password = {
    sopsFile = ../../secrets/production/database.yaml;
    owner = "postgres";
  };
};
```

### Binary Secrets

For binary files (like GPG keys):

```bash
# Encrypt binary file
sops --encrypt --input-type binary --output-type binary \
  /path/to/file.bin > secrets/file.bin.enc

# Decrypt
sops --decrypt --input-type binary --output-type binary \
  secrets/file.bin.enc > /tmp/file.bin
```

### Template Secrets

Use secrets in configuration files:

```nix
sops.templates.docker-config = {
  content = ''
    {
      "auths": {
        "registry.example.com": {
          "username": "${config.sops.placeholder.docker_username}",
          "password": "${config.sops.placeholder.docker_password}"
        }
      }
    }
  '';
  owner = "borba";
  path = "/home/borba/.docker/config.json";
};

sops.secrets.docker_username = {};
sops.secrets.docker_password = {};
```

## Best Practices

### ✅ DO:

1. **Use age over GPG** - Simpler, more modern
2. **Use SSH-derived age keys** - Easier key management
3. **Store age key outside Git** - Never commit `keys.txt`
4. **One secret per purpose** - Don't reuse passwords
5. **Use templates for config files** - Inject secrets at runtime
6. **Backup age key** - Store in password manager
7. **Rotate secrets regularly** - Update keys periodically
8. **Use host-specific secrets** - Minimize blast radius

### ❌ DON'T:

1. **Don't commit unencrypted secrets** - Ever
2. **Don't share age private keys** - Generate per-admin
3. **Don't hardcode secrets in Nix** - Use sops
4. **Don't use weak passwords** - Use generators
5. **Don't skip .sops.yaml** - Required for correct encryption

### Security Checklist

- [ ] Age keys generated and secured
- [ ] `.sops.yaml` configured correctly
- [ ] `keys.txt` in `.gitignore`
- [ ] Secrets encrypted before commit
- [ ] File permissions set correctly (0600 for private)
- [ ] Backup of age key exists
- [ ] GitHub tokens use minimal scopes
- [ ] SSH keys have passphrase (optional but recommended)

## Troubleshooting

### Cannot decrypt secrets

**Error:** `failed to get the data key required to decrypt the SOPS file`

**Solution:**
```bash
# Verify age key exists
cat ~/.config/sops/age/keys.txt

# Check .sops.yaml has correct public key
age-keygen -y ~/.config/sops/age/keys.txt
# Compare with .sops.yaml

# Re-encrypt with correct key
sops updatekeys secrets/common/secrets.yaml
```

### Permission denied on secrets

**Error:** `Permission denied: /run/secrets/secret_name`

**Solution:**
```nix
sops.secrets.secret_name = {
  owner = "borba";  # Set correct owner
  mode = "0600";    # Ensure readable by owner
};
```

### Secrets not updating

```bash
# Remove old secrets
sudo rm -rf /run/secrets/*

# Rebuild
sudo nixos-rebuild switch --flake .#hostname
```

### Age key not found

**Error:** `age key file not found`

**Solution:**
```bash
# Generate from SSH key
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### SOPS editor issues

Set editor explicitly:

```bash
export EDITOR=nvim
sops secrets/common/secrets.yaml
```

## Common Workflows

### Adding a New Secret

```bash
# 1. Edit secrets file
sops secrets/common/secrets.yaml

# 2. Add secret key-value
new_api_key: sk_your_secret_key

# 3. Save and exit (auto-encrypts)

# 4. Use in NixOS config
sops.secrets.new_api_key = {
  owner = "borba";
};

# 5. Rebuild
sudo nixos-rebuild switch --flake .#hostname
```

### Rotating Age Key

```bash
# 1. Generate new age key
ssh-to-age -private-key -i ~/.ssh/id_ed25519_new > ~/.config/sops/age/keys-new.txt

# 2. Get new public key
ssh-to-age < ~/.ssh/id_ed25519_new.pub

# 3. Update .sops.yaml with new public key

# 4. Re-encrypt all secrets
find secrets -name "*.yaml" -exec sops updatekeys {} \;

# 5. Replace old key with new
mv ~/.config/sops/age/keys-new.txt ~/.config/sops/age/keys.txt

# 6. Rebuild
sudo nixos-rebuild switch --flake .#hostname
```

### Migrating from Plaintext

```bash
# 1. Create secrets file
sops secrets/common/secrets.yaml

# 2. Add current plaintext values

# 3. Update NixOS config to use secrets
# Before:
services.foo.apiKey = "hardcoded_key";

# After:
services.foo.apiKey = config.sops.secrets.foo_api_key.path;

# 4. Rebuild and verify

# 5. Remove plaintext from config
```

## References

- [sops-nix GitHub](https://github.com/Mic92/sops-nix)
- [SOPS Documentation](https://github.com/getsops/sops)
- [Age Encryption](https://age-encryption.org/)
- [NixOS Wiki - Secrets](https://nixos.wiki/wiki/Comparison_of_secret_managing_schemes)

## File Structure

```
nixos-config/
├── .sops.yaml                    # SOPS configuration
├── secrets/                      # Encrypted secrets directory
│   ├── common/
│   │   ├── secrets.yaml         # Shared secrets
│   │   ├── ssh-keys.yaml        # SSH keys
│   │   └── api-tokens.yaml      # API tokens
│   ├── macbook/
│   │   └── secrets.yaml         # MacBook-specific
│   └── dell/
│       └── secrets.yaml         # Dell-specific
├── modules/
│   └── system/
│       └── secrets.nix          # Secrets configuration
└── .gitignore                   # Ignore keys.txt

# NOT in Git (local only):
~/.config/sops/age/keys.txt      # Age private key
```

---

**Last Updated:** 2026-02-02  
**Version:** 1.0  
**Author:** NixOS Configuration - waldirborbajr
