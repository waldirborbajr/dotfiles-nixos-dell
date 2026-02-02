# Common Secrets

Shared secrets used across all hosts (MacBook and Dell).

## Files

- `secrets.yaml` - General shared secrets
- `ssh-keys.yaml` - SSH keys for Git/GitHub
- `api-tokens.yaml` - API tokens and credentials

## Usage

```bash
# Edit secrets
sops secrets/common/secrets.yaml

# View secrets
sops -d secrets/common/secrets.yaml
```

## Example Structure

```yaml
# secrets.yaml
ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----

ssh_public_key: ssh-ed25519 AAAAC3... user@host

github_token: ghp_yourtoken

tailscale_auth_key: tskey-auth-yourkey
```
