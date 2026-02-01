# ==========================================
# NixOS Infra Justfile (Borba - NixGuru edition)
# Goals:
# - idiot-proof UX (clear errors, safe defaults)
# - reproducible + debuggable
# - auto-commit + push sempre para build/switch/switch-prod
# ==========================================

# Settings
set shell := ["bash", "-euo", "pipefail", "-c"]
set dotenv-load := true

# Variables
NIXOS_CONFIG := env_var_or_default("NIXOS_CONFIG", env_var("HOME") + "/nixos-config")
DEBUG_LOG := "/tmp/nixos-build-debug.log"
GIT_PUSH := env_var_or_default("GIT_PUSH", "1")
AUTO_UPDATE_FLAKE := env_var_or_default("AUTO_UPDATE_FLAKE", "0")
AUTO_GIT_COMMIT := env_var_or_default("AUTO_GIT_COMMIT", "1")

# Get current timestamp for commit messages
_git_commit_msg := "wip(justfile): " + `date '+%Y-%m-%d %H:%M'`

# ==========================================
# Default recipe (shows grouped commands)
# ==========================================
default:
    @just --list

# ==========================================
# Discovery / Diagnostics
# ==========================================

# List available hosts from flake
[group: 'discovery']
hosts:
    #!/usr/bin/env bash
    if [[ ! -e "{{NIXOS_CONFIG}}/flake.nix" ]]; then
        echo "ERROR: flake.nix not found in: {{NIXOS_CONFIG}}"
        exit 1
    fi
    echo "Available hosts from flake outputs:"
    cd {{NIXOS_CONFIG}} && nix --extra-experimental-features "nix-command flakes" flake show --json \
        | jq -r '.nixosConfigurations | keys[]' 2>/dev/null || \
        (echo "HINT: install jq for pretty listing, or run: just flake-show"; exit 0)

# Show full flake outputs
[group: 'discovery']
flake-show:
    cd {{NIXOS_CONFIG}} && nix --extra-experimental-features "nix-command flakes" flake show

# Check system health
[group: 'discovery']
doctor:
    #!/usr/bin/env bash
    if [[ ! -e "{{NIXOS_CONFIG}}/flake.nix" ]]; then
        echo "ERROR: flake.nix not found in: {{NIXOS_CONFIG}}"
        exit 1
    fi
    if ! command -v nix >/dev/null 2>&1; then
        echo "ERROR: nix command not found."
        exit 1
    fi
    if ! nix --extra-experimental-features "nix-command flakes" flake show "{{NIXOS_CONFIG}}" >/dev/null 2>&1; then
        echo "ERROR: flakes not working or flake is invalid."
        exit 1
    fi
    echo "OK: repo + nix + flakes look good."
    echo "Repo: {{NIXOS_CONFIG}}"
    echo "Tip: just hosts"

# ==========================================
# Validation
# ==========================================

# Fast syntax validation with flake check
[group: 'validation']
flake-check:
    @echo "Running flake check (fast sanity)..."
    cd {{NIXOS_CONFIG}} && nix --extra-experimental-features "nix-command flakes" flake check

# Check flake syntax with --impure
[group: 'validation']
check:
    @echo "Verificando sintaxe do flake com --impure..."
    cd {{NIXOS_CONFIG}} && nix --extra-experimental-features "nix-command flakes" flake check --impure
    @echo "✓ Sintaxe OK!"

# Evaluate host configuration
[group: 'validation']
eval-host HOST:
    #!/usr/bin/env bash
    if [[ -z "{{HOST}}" ]]; then
        echo "ERROR: HOST is required."
        echo "HINT: just hosts"
        echo "EX: just eval-host macbook"
        exit 1
    fi
    echo "Evaluating toplevel drvPath for host {{HOST}}..."
    cd {{NIXOS_CONFIG}} && nix --extra-experimental-features "nix-command flakes" eval --raw \
        ".#nixosConfigurations.{{HOST}}.config.system.build.toplevel.drvPath"

# ==========================================
# Git operations
# ==========================================

# Update flake.lock
[group: 'git']
update-flake:
    @echo "Updating flake.lock in {{NIXOS_CONFIG}}..."
    cd {{NIXOS_CONFIG}} && nix --extra-experimental-features "nix-command flakes" flake update

# Auto-commit and push changes
[group: 'git']
[private]
_check_git_status:
    #!/usr/bin/env bash
    echo "Checking Git status in {{NIXOS_CONFIG}}..."
    cd {{NIXOS_CONFIG}}
    if [ -z "$(git status --porcelain)" ]; then
        echo "Git tree clean. No changes."
    else
        echo "Git changes detected → auto add / commit / push..."
        git add .
        git commit -m "{{_git_commit_msg}}" || { echo "Commit skipped (nothing new after add)"; true; }
        if [ "{{GIT_PUSH}}" = "1" ]; then
            git push origin main || { echo "Push falhou (pode ser auth/upstream). Continuando..."; true; }
        fi
    fi

# ==========================================
# Build / Switch
# ==========================================

# Internal: validate host parameter
[group: 'build']
[private]
_require_host HOST:
    #!/usr/bin/env bash
    if [[ -z "{{HOST}}" ]]; then
        echo "ERROR: HOST is required."
        echo "HINT: just hosts # list available hosts"
        echo "EX: just switch macbook"
        exit 1
    fi
    echo "Validating flake host: {{HOST}}..."
    if ! nix --extra-experimental-features "nix-command flakes" eval --raw \
        "{{NIXOS_CONFIG}}#nixosConfigurations.{{HOST}}.config.system.build.toplevel.drvPath" \
        >/dev/null 2>&1; then
        echo "ERROR: HOST='{{HOST}}' not found in flake outputs."
        echo "HINT: just hosts"
        exit 1
    fi

# Internal: build nixos-rebuild command
[group: 'build']
[private]
_nixos_cmd HOST ACTION DEVOPS="" QEMU="" IMPURE="" FLAGS="":
    #!/usr/bin/env bash
    CMD="sudo nixos-rebuild {{ACTION}} --flake {{NIXOS_CONFIG}}#{{HOST}}"
    [[ -n "{{IMPURE}}" ]] && CMD="$CMD --impure"
    [[ -n "{{FLAGS}}" ]] && CMD="$CMD {{FLAGS}}"
    [[ -n "{{DEVOPS}}" ]] && export DEVOPS=1
    [[ -n "{{QEMU}}" ]] && export QEMU=1
    echo ">>> Running: $CMD"
    eval $CMD

# Dry run switch
[group: 'build']
dry-switch HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}} "--dry-run"

# Dry run build
[group: 'build']
dry-build HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @just _nixos_cmd {{HOST}} build {{DEVOPS}} {{QEMU}} {{IMPURE}} "--dry-run"

# Test build (não aplica mudanças)
[group: 'build']
test-build HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @echo "Test build (não aplica mudanças) para host: {{HOST}}"
    @just _nixos_cmd {{HOST}} build {{DEVOPS}} {{QEMU}} {{IMPURE}}
    @echo "✓ Test build concluído! Nenhuma mudança foi aplicada."
    @echo "Para aplicar mudanças: just switch {{HOST}}"

# Build system configuration
[group: 'build']
build HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @[ "{{AUTO_UPDATE_FLAKE}}" = "1" ] && just update-flake || echo "AUTO_UPDATE_FLAKE=0 → skipping flake update."
    @just _check_git_status
    @just flake-check
    @echo "Before:" && just current-system
    @just _nixos_cmd {{HOST}} build {{DEVOPS}} {{QEMU}} {{IMPURE}}
    @echo "After:" && just current-system && just list-generations

# Switch to new configuration
[group: 'build']
switch HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @[ "{{AUTO_UPDATE_FLAKE}}" = "1" ] && just update-flake || echo "AUTO_UPDATE_FLAKE=0 → skipping flake update."
    @just _check_git_status
    @echo "Before:" && just current-system
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}}
    @echo "After:" && just current-system && just list-generations

# Production switch (with flake check)
[group: 'build']
switch-prod HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @[ "{{AUTO_UPDATE_FLAKE}}" = "1" ] && just update-flake || echo "AUTO_UPDATE_FLAKE=0 → skipping flake update."
    @just _check_git_status
    @just flake-check
    @echo "Before:" && just current-system
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}}
    @echo "After:" && just current-system && just list-generations

# Switch without GUI (multi-user.target)
[group: 'build']
switch-off HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    sudo systemctl isolate multi-user.target
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}}
    sudo systemctl isolate graphical.target

# Upgrade system (update flake + switch)
[group: 'build']
upgrade HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @just update-flake
    @just _check_git_status
    @just flake-check
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}}
    @just list-generations

# Debug build with verbose output
[group: 'build']
build-debug HOST DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @[ "{{AUTO_UPDATE_FLAKE}}" = "1" ] && just update-flake || echo "AUTO_UPDATE_FLAKE=0 → skipping flake update."
    @just _check_git_status
    @just flake-check
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}} "--verbose --show-trace" 2>&1 | tee {{DEBUG_LOG}}
    @echo "Saved log: {{DEBUG_LOG}}"

# ==========================================
# Generations / Rollback
# ==========================================

# List recent system generations
[group: 'maintenance']
list-generations:
    @echo ""
    @sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 30

# Show current system profile
[group: 'maintenance']
current-system:
    @echo "Current system -> $(readlink -f /run/current-system)"
    @echo "System profile -> $(readlink -f /nix/var/nix/profiles/system)"

# Explain why generations might not advance
[group: 'maintenance']
why-no-new-generation:
    @echo "If generations don't advance, one of these is true:"
    @echo " 1) build output is identical (toplevel didn't change)"
    @echo " 2) your module isn't imported for this host"
    @echo " 3) rebuild failed before activation"
    @echo ""
    @echo "Current pointers:" && just current-system
    @echo "" && echo "Recent generations:" && just list-generations

# Rollback to previous generation
[group: 'maintenance']
rollback CONFIRM="":
    #!/usr/bin/env bash
    if [[ "{{CONFIRM}}" != "YES" ]]; then
        echo "Refusing to rollback without explicit confirmation."
        echo "Run: just rollback YES"
        exit 1
    fi
    sudo nixos-rebuild switch --rollback
    just list-generations

# ==========================================
# Maintenance
# ==========================================

# Format Nix files (only tracked by git)
[group: 'maintenance']
fmt:
    @echo "Formatting Nix files..."
    cd {{NIXOS_CONFIG}} && nix fmt
    @echo "✓ Formatação concluída!"
    git -C {{NIXOS_CONFIG}} status --short

# Format specific file or directory
[group: 'maintenance']
fmt-path PATH:
    @echo "Formatting: {{PATH}}"
    cd {{NIXOS_CONFIG}} && nix run nixpkgs#nixpkgs-fmt -- {{PATH}}
    @echo "✓ Formatação de {{PATH}} concluída!"

# Format only tracked Nix files (explicit, safe)
[group: 'maintenance']
fmt-tracked:
    @echo "Formatting tracked .nix files..."
    cd {{NIXOS_CONFIG}} && git ls-files '*.nix' | xargs nixpkgs-fmt
    @echo "✓ Formatação concluída!"
    git -C {{NIXOS_CONFIG}} status --short

# Check systemd user jobs
[group: 'maintenance']
status:
    systemctl --user list-jobs

# Garbage collect (safe)
[group: 'maintenance']
gc:
    sudo nix-collect-garbage

# Aggressive garbage collection
[group: 'maintenance']
gc-hard CONFIRM="":
    #!/usr/bin/env bash
    if [[ "{{CONFIRM}}" != "YES" ]]; then
        echo "Refusing to run destructive GC without explicit confirmation."
        echo "Run: just gc-hard YES"
        exit 1
    fi
    sudo nix-collect-garbage -d --delete-older-than 1d
