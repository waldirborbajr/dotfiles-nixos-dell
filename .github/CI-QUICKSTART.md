# CI/CD Quick Start Guide

## 🎯 Purpose

This CI/CD pipeline **prevents broken configurations from reaching production**. Every push/PR is automatically validated to ensure all hosts build successfully and devshells work.

---

## 🚀 Quick Start

### Before Pushing Changes

Always test locally first:

```bash
# Run all CI checks (recommended)
./scripts/test-all.sh

# Output will show:
# ✅ PASSED: Flake and structure validation
# ✅ PASSED: Full flake validation  
# ✅ PASSED: Build macbook config
# ❌ FAILED: Build dell config  # Example failure
```

### After Pushing

1. Go to: https://github.com/waldirborbajr/nixos-config/actions
2. Watch the CI pipeline run automatically
3. Check the summary for pass/fail status
4. Download logs if something fails

---

## 📋 What Gets Tested

### 1. Flake Check (`flake-check`)
```bash
nix flake check --show-trace
```

**What it validates:**
- Flake syntax is correct
- All inputs are accessible
- No circular dependencies
- Devshells evaluate correctly
- NixOS configurations are valid

**Common failures:**
- ❌ `error: undefined variable` → Missing import
- ❌ `error: infinite recursion` → Circular dependency
- ❌ `syntax error` → Missing semicolon or bracket

### 2. Build Configurations (`build-configs`)
```bash
nix build .#nixosConfigurations.macbook.config.system.build.toplevel
nix build .#nixosConfigurations.dell.config.system.build.toplevel
```

**What it validates:**
- Both hosts build completely
- No missing packages
- No conflicting options
- All modules load correctly

**Common failures:**
- ❌ `package not found` → Package name typo or removed from nixpkgs
- ❌ `option conflict` → Two modules setting same option
- ❌ `assertion failed` → Incompatible configuration

### 3. Evaluate Devshells (`eval-devshells`)
```bash
nix develop .#rust --command echo "✅ OK"
nix develop .#go --command echo "✅ OK"
# ... tests all 11 shells
```

**What it validates:**
- All devshells can be entered
- No missing dependencies
- Build inputs are available

**Common failures:**
- ❌ `attribute missing` → Shell not defined in flake
- ❌ `package not found` → Tool not available in nixpkgs

### 4. Format Check (`format-check`)
```bash
nix fmt -- --check .
```

**What it validates:**
- Consistent Nix code style
- No formatting inconsistencies

**Fix:**
```bash
nix fmt  # Auto-format all files
```

---

## 🔧 Local Testing Examples

### Test Everything
```bash
./scripts/test-all.sh

# Output:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   🔍 NixOS Configuration - Local CI Runner
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
# This script runs all CI checks locally before pushing.
# It may take several minutes depending on your machine.
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   1️⃣  Sanity Checks
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
# ▶ Running: Flake and structure validation
# ==> Running sanity checks
# ✅ File structure OK
# ...
```

### Test Specific Host
```bash
./scripts/ci-build.sh macbook

# ==> Building NixOS configuration: macbook
# building '/nix/store/...-nixos-system-macbook-24.11.drv'...
# ✅ Build succeeded for macbook
# Result: /nix/store/...-nixos-system-macbook-24.11
# 5.2G    result
```

### Test Just Flake
```bash
./scripts/ci-checks.sh

# ==> Running sanity checks
# ✅ File structure OK
# ==> Running nix flake check
# evaluating flake...
# checking flake output 'formatter'...
# checking NixOS configuration 'nixosConfigurations.macbook'...
# ✅ All sanity checks passed
```

### Test Devshells
```bash
./scripts/ci-eval.sh

# ==> Evaluating all NixOS configurations
# Evaluating: macbook
# ✅ Configuration macbook OK
# 
# Evaluating: dell
# ✅ Configuration dell OK
# 
# ==> Evaluating all devshells
# Evaluating devshell: rust
# ✅ Devshell rust OK
# ...
```

---

## 🐛 Troubleshooting Common Failures

### Problem: "Package not found"
```
error: attribute 'some-package' missing
```

**Solution:**
1. Check package name: https://search.nixos.org
2. Verify nixpkgs version has the package
3. Update flake.lock: `nix flake update`

### Problem: "Option conflict"
```
error: The option 'programs.zsh.shellAliases.rg' has conflicting definition values
```

**Solution:**
1. Use `lib.mkForce` to override
2. Or use `lib.mkDefault` for default values
3. Remove duplicate definitions

### Problem: "Flake check fails but builds work"
```
error: Package 'broadcom-sta' is marked as insecure
```

**Solution:**
1. Add to `permittedInsecurePackages` in host config
2. Or mark the check as `continue-on-error: true` in CI
3. The workflow already handles Dell's broadcom-sta

### Problem: "CI passes but local build fails"
```
error: Path 'modules/desktops/niri' is not tracked by Git
```

**Solution:**
```bash
git add modules/desktops/niri/
# Nix flakes only see Git-tracked files!
```

---

## ⚡ Performance Tips

### Use Cachix (Optional)
Speed up CI builds by caching derivations:

1. Sign up: https://cachix.org
2. Create cache or use `nix-community`
3. Add `CACHIX_AUTH_TOKEN` to GitHub secrets
4. CI will automatically use cache

**Result:** Builds go from 10+ minutes → seconds

### Local Build Cache
```bash
# First build (slow)
./scripts/ci-build.sh macbook  # ~15 min

# Subsequent builds (fast)
./scripts/ci-build.sh macbook  # ~1 min (cached)
```

---

## 📊 CI Status & Reports

### View CI Results
- **Actions Tab:** https://github.com/waldirborbajr/nixos-config/actions
- **Badge in README:** Shows current branch status
- **PR Checks:** Detailed per-job status

### Download Build Logs
1. Click on failed job
2. Scroll to "Artifacts" section
3. Download `build-log-{host}` or `flake-check-log`
4. Review error messages

### Summary Report
Each CI run generates a summary showing:
```
🔍 NixOS Configuration CI Summary

| Job          | Status      |
|--------------|-------------|
| Flake Check  | ✅ Passed   |
| Build Configs| ✅ Passed   |
| Devshells    | ✅ Passed   |
| Format Check | ⚠️ Skipped  |

Commit: cf11574
Branch: REFACTORv2
```

---

## 🎓 Best Practices

### Before Every Commit
1. ✅ Run `./scripts/test-all.sh` locally
2. ✅ Fix any failures before pushing
3. ✅ Run `nix fmt` to format code
4. ✅ Check `git status` for untracked files

### When Adding New Features
1. ✅ Add to appropriate module
2. ✅ Test with `nix build .#nixosConfigurations.{host}.config.system.build.toplevel`
3. ✅ Update documentation
4. ✅ Push and verify CI passes

### When Modifying Devshells
1. ✅ Test shell enters: `nix develop .#rust`
2. ✅ Test tools work: `nix develop .#rust --command rustc --version`
3. ✅ Run `./scripts/ci-eval.sh` to test all shells

---

## 🔒 Branch Protection (Recommended)

For production branches (main, REFACTORv2):

1. Go to: Settings → Branches → Branch protection rules
2. Add rule for `REFACTORv2`
3. Enable:
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - ✅ Require `Nix Flake Check` passing

**Result:** Broken configs cannot be merged!

---

## 📚 Additional Resources

- **CI Workflow:** [.github/workflows/ci.yml](../.github/workflows/ci.yml)
- **Workflow Docs:** [.github/workflows/README.md](./README.md)
- **Main README:** [../README.md](../README.md)
- **Nix Manual:** https://nixos.org/manual/nix/stable/
- **Nix Flakes:** https://nixos.wiki/wiki/Flakes
