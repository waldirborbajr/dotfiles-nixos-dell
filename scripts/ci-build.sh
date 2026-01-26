#!/usr/bin/env bash
# CI Script: Build NixOS configurations
set -euo pipefail

HOST="${1:-macbook}"

echo "==> Building NixOS configuration: $HOST"

# Build the system configuration
nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
    --print-build-logs \
    --show-trace \
    2>&1 | tee "/tmp/build-$HOST.log"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "\n✅ Build succeeded for $HOST"
    
    # Show the result path
    if [ -L result ]; then
        echo "Result: $(readlink -f result)"
        du -sh result
    fi
else
    echo "\n❌ Build failed for $HOST! See /tmp/build-$HOST.log"
    exit 1
fi
