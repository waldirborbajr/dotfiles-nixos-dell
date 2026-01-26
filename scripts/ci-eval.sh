#!/usr/bin/env bash
# CI Script: Evaluate all devshells and configurations
set -euo pipefail

echo "==> Evaluating all NixOS configurations"

for HOST in macbook dell; do
    echo "\nEvaluating: $HOST"
    nix eval ".#nixosConfigurations.$HOST.config.system.name" \
        --show-trace || {
        echo "❌ Failed to evaluate $HOST"
        exit 1
    }
    echo "✅ Configuration $HOST OK"
done

echo "\n==> Evaluating all devshells"

SHELLS=("default" "rust" "rust-nightly" "go" "lua" "nix-dev" "fullstack" "devops" "postgresql" "mariadb" "sqlite" "databases")

for SHELL in "${SHELLS[@]}"; do
    echo "\nEvaluating devshell: $SHELL"
    nix develop ".#$SHELL" --command echo "✅ Devshell $SHELL OK" || {
        echo "❌ Failed to evaluate devshell $SHELL"
        exit 1
    }
done

echo "\n✅ All evaluations successful"
