#!/usr/bin/env bash
# CI Script: Flake validation and sanity checks
set -euo pipefail

echo "==> Running sanity checks"

# Check required files and directories
test -f flake.nix || { echo "❌ flake.nix not found"; exit 1; }
test -f flake.lock || { echo "❌ flake.lock not found"; exit 1; }
test -d modules || { echo "❌ modules/ directory not found"; exit 1; }
test -d hosts || { echo "❌ hosts/ directory not found"; exit 1; }

echo "✅ File structure OK"

# Show directory tree
if command -v tree &> /dev/null; then
    echo "\n==> Directory structure:"
    tree -L 2 -I 'result'
fi

echo "\n==> Running nix flake check"
nix flake check --show-trace 2>&1 | tee /tmp/flake-check.log || {
    echo "\n❌ Flake check failed! See /tmp/flake-check.log for details"
    exit 1
}

echo "\n✅ All sanity checks passed"
