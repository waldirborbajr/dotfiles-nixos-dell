# GitHub Actions Workflows

## CI Pipeline (`ci.yml`)

Automated validation of NixOS configuration on every push/PR.

### What it checks

1. **Flake Check** - Validates flake syntax and structure
2. **Build Configs** - Attempts to build both `macbook` and `dell` configurations
3. **Devshells** - Evaluates all development shells (Rust, Go, Lua, databases, etc.)
4. **Format Check** - Verifies Nix code formatting

### Jobs Breakdown

#### 1. Flake Check (`flake-check`)
- Runs `nix flake check` to validate the entire flake
- Uploads logs for debugging
- Uses Cachix for faster builds (optional)

#### 2. Build Configurations (`build-configs`)
- Builds each host configuration in parallel
- Tests `macbook` and `dell` separately
- Continues even if one fails (fail-fast: false)
- Uploads build logs as artifacts

#### 3. Evaluate Devshells (`eval-devshells`)
- Tests all 11 development shells
- Ensures devshells can be entered without errors
- Matrix strategy for parallel execution

#### 4. Format Check (`format-check`)
- Runs `nixpkgs-fmt` on all Nix files
- Ensures consistent code style

#### 5. Summary Report (`summary`)
- Generates a consolidated report
- Shows pass/fail status for all jobs
- Visible in GitHub Actions UI

### Artifacts

- **flake-check-log** - Output from `nix flake check`
- **build-log-{host}** - Build logs for each host

Artifacts are retained for 7 days.

### Configuration

#### Optional: Cachix Setup
To speed up builds, add `CACHIX_AUTH_TOKEN` to repository secrets:
1. Sign up at https://cachix.org
2. Create a cache (or use `nix-community`)
3. Add token to GitHub repo: Settings → Secrets → Actions → New repository secret

#### Branch Protection
Recommended settings for `main` branch:
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Require `Nix Flake Check` job

### Triggering Manually

You can manually trigger the workflow:
1. Go to Actions tab
2. Select "NixOS Configuration CI"
3. Click "Run workflow"

### Local Testing

Before pushing, run these commands locally:

```bash
# Flake check
nix flake check

# Build specific host
nix build .#nixosConfigurations.macbook.config.system.build.toplevel

# Test devshell
nix develop .#rust

# Format check
nix fmt -- --check .

# Or use the CI scripts directly
./scripts/ci-checks.sh
./scripts/ci-build.sh macbook
./scripts/ci-eval.sh
```

### Troubleshooting

**Problem:** Build fails with "insecure package" error  
**Solution:** The CI allows insecure packages for Dell (broadcom-sta). Check `extra_nix_config` in workflow.

**Problem:** Flake check takes too long  
**Solution:** Set up Cachix to cache build artifacts between runs.

**Problem:** Format check fails  
**Solution:** Run `nix fmt` locally to auto-format before committing.

### CI Status Badge

Add to your README.md:

```markdown
[![CI](https://github.com/waldirborbajr/nixos-config/workflows/NixOS%20Configuration%20CI/badge.svg?branch=REFACTORv2)](https://github.com/waldirborbajr/nixos-config/actions)
```
