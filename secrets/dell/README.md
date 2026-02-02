# Dell-Specific Secrets

Secrets used only on the Dell host.

## Files

- `secrets.yaml` - Dell-specific secrets

## Usage

```bash
# Edit secrets
sops secrets/dell/secrets.yaml

# View secrets
sops -d secrets/dell/secrets.yaml
```

## Example Structure

```yaml
# secrets.yaml
wifi_password: dell_wifi_password

backup_encryption_key: your_backup_key

production_db_password: secure_db_password
```
