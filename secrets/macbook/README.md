# MacBook-Specific Secrets

Secrets used only on the MacBook host.

## Files

- `secrets.yaml` - MacBook-specific secrets

## Usage

```bash
# Edit secrets
sops secrets/macbook/secrets.yaml

# View secrets
sops -d secrets/macbook/secrets.yaml
```

## Example Structure

```yaml
# secrets.yaml
wifi_password: your_home_wifi_password

vpn_config: |
  [connection]
  id=Work VPN
  ...

development_api_key: dev_key_for_testing
```
