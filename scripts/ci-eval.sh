#!/usr/bin/env bash
set -euo pipefail

echo "==> Evaluating NixOS configuration"

nix-instantiate \
  '<nixpkgs/nixos>' \
  -A system \
  -I nixos-config=./configuration.nix \
  >/dev/null

echo "✔ Evaluation successful"
