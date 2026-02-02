# Secrets Directory

This directory contains encrypted secrets managed by **sops-nix**.

## Directory Structure

- `common/` - Secrets shared across all hosts
- `macbook/` - MacBook-specific secrets
- `dell/` - Dell-specific secrets

## Important

⚠️ **Only commit encrypted `.yaml` files!**

- ✅ Commit: `secrets.yaml` (encrypted by SOPS)
- ❌ Never commit: `.sops.yaml`, `keys.txt`, unencrypted files

## Quick Start

See [SECRETS-MANAGEMENT.md](../SECRETS-MANAGEMENT.md) for complete documentation.

```bash
# Create/edit encrypted secrets
sops secrets/common/secrets.yaml

# View decrypted content
sops -d secrets/common/secrets.yaml
```

## Verify Encryption

Before committing, ensure files are encrypted:

```bash
# Encrypted file should show:
cat secrets/common/secrets.yaml
# Output: Binary/gibberish encrypted content with "sops" markers

# If you see plaintext, DON'T COMMIT!
```
