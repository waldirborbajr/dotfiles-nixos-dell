# ==========================================
# NixOS Infra Makefile (Borba - FINAL)
# Goal: ZERO "missing separator"/indentation hell
# Strategy: Make only writes + runs a Bash script. Bash does everything.
# Works on NixOS without /bin/bash and without /usr/bin/env.
# ==========================================

.DEFAULT_GOAL := help

# NixOS canonical paths (do NOT use /bin/bash or /usr/bin/env)
BASH := /run/current-system/sw/bin/bash
SUDO := /run/wrappers/bin/sudo

# Repo path (auto-detect if running inside nixos-config)
NIXOS_CONFIG ?= $(if $(wildcard $(CURDIR)/flake.nix),$(CURDIR),$(HOME)/nixos-config)

# Script output
SCRIPT := ./.nixosctl

# Flags (passed through)
HOST ?=
IMPURE ?=
DEVOPS ?=
QEMU ?=

AUTO_UPDATE_FLAKE ?= 0
AUTO_GIT_COMMIT ?= 1
GIT_COMMIT_MSG ?= chore: auto-commit before rebuild
GIT_PUSH ?=
DEBUG_LOG ?= /tmp/nixos-build-debug.log

.PHONY: help gen doctor hosts flake-show flake-check update-flake fmt current-system list-generations \
        build switch dry-build dry-switch build-debug rollback gc gc-hard

help:
	@echo "NixOS Infra (flakes) — FINAL (script-based, no Make indentation hell)"
	@echo ""
	@echo "Usage:"
	@echo "  make doctor"
	@echo "  make hosts"
	@echo "  make switch HOST=macbook [DEVOPS=1] [QEMU=1] [IMPURE=1]"
	@echo ""
	@echo "Options:"
	@echo "  AUTO_UPDATE_FLAKE=1  (default 0)"
	@echo "  AUTO_GIT_COMMIT=0    (default 1)"
	@echo ""

gen:
	@cat > "$(SCRIPT)" <<'EOF'
#! /run/current-system/sw/bin/bash
set -euo pipefail

# -----------------------------
# Config from Make env
# -----------------------------
NIXOS_CONFIG="${NIXOS_CONFIG:-$HOME/nixos-config}"

HOST="${HOST:-}"
IMPURE="${IMPURE:-}"
DEVOPS="${DEVOPS:-}"
QEMU="${QEMU:-}"

AUTO_UPDATE_FLAKE="${AUTO_UPDATE_FLAKE:-0}"
AUTO_GIT_COMMIT="${AUTO_GIT_COMMIT:-1}"
GIT_COMMIT_MSG="${GIT_COMMIT_MSG:-chore: auto-commit before rebuild}"
GIT_PUSH="${GIT_PUSH:-}"
DEBUG_LOG="${DEBUG_LOG:-/tmp/nixos-build-debug.log}"

SUDO="/run/wrappers/bin/sudo"
NIX="nix --extra-experimental-features nix-command --extra-experimental-features flakes"

die() { echo "ERROR: $*" >&2; exit 1; }

need_file() { [[ -f "$1" ]] || die "missing file: $1"; }
need_exec() { [[ -x "$1" ]] || die "missing executable: $1"; }

preflight() {
  need_exec "/run/current-system/sw/bin/bash"
  need_exec "$SUDO"
  command -v nix >/dev/null 2>&1 || die "nix not found in PATH"
  command -v nixos-rebuild >/dev/null 2>&1 || die "nixos-rebuild not found in PATH"
  need_file "$NIXOS_CONFIG/flake.nix"
  [[ -n "$HOST" ]] || die "HOST is required. Example: make switch HOST=macbook"
}

show_flags() {
  echo "Repo:  $NIXOS_CONFIG"
  echo "Flags: HOST=$HOST IMPURE=$IMPURE DEVOPS=$DEVOPS QEMU=$QEMU"
}

require_flake_host() {
  echo "Validating host '$HOST' in flake outputs..."
  if $NIX eval --raw "$NIXOS_CONFIG#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" >/dev/null; then
    echo "OK: host exists."
  else
    echo ""
    echo "Nix evaluation failed. Real error output:"
    echo "----------------------------------------"
    $NIX eval --raw "$NIXOS_CONFIG#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" || true
    echo "----------------------------------------"
    exit 1
  fi
}

maybe_update_flake() {
  if [[ "$AUTO_UPDATE_FLAKE" == "1" ]]; then
    echo "AUTO_UPDATE_FLAKE=1 -> nix flake update"
    (cd "$NIXOS_CONFIG" && $NIX flake update)
  else
    echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update"
  fi
}

maybe_git_commit() {
  if [[ "$AUTO_GIT_COMMIT" != "1" ]]; then
    echo "AUTO_GIT_COMMIT=0 -> skipping auto-commit"
    return 0
  fi
  if ! command -v git >/dev/null 2>&1; then
    echo "git not found -> skipping auto-commit"
    return 0
  fi
  if [[ -n "$(git -C "$NIXOS_CONFIG" status --porcelain)" ]]; then
    echo "Git changes detected -> add/commit..."
    git -C "$NIXOS_CONFIG" add .
    git -C "$NIXOS_CONFIG" commit -m "$GIT_COMMIT_MSG" || true
    if [[ "$GIT_PUSH" == "1" ]]; then
      git -C "$NIXOS_CONFIG" push
    fi
  else
    echo "No git changes detected."
  fi
}

print_cmd() {
  local action="$1"
  local extra="${2:-}"
  echo ">>> ${DEVOPS:+DEVOPS=1 }${QEMU:+QEMU=1 }$SUDO nixos-rebuild $action --flake $NIXOS_CONFIG#$HOST ${IMPURE:+--impure }$extra"
}

run_rebuild() {
  local action="$1"
  local extra="${2:-}"
  local envs=()
  [[ -n "$DEVOPS" ]] && envs+=( "DEVOPS=1" )
  [[ -n "$QEMU"  ]] && envs+=( "QEMU=1" )

  if [[ -n "$extra" ]]; then
    "${envs[@]}" $SUDO nixos-rebuild "$action" --flake "$NIXOS_CONFIG#$HOST" ${IMPURE:+--impure} $extra
  else
    "${envs[@]}" $SUDO nixos-rebuild "$action" --flake "$NIXOS_CONFIG#$HOST" ${IMPURE:+--impure}
  fi
}

current_system() {
  echo "Current system: $(readlink -f /run/current-system)"
  echo "Profile:        $(readlink -f /nix/var/nix/profiles/system)"
}

list_generations() {
  echo ""
  $SUDO nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 60
}

case "${1:-}" in
  doctor)
    preflight
    show_flags
    echo "OK: repo + tools present"
    ;;
  hosts)
    preflight
    echo "nixosConfigurations:"
    $NIX flake show "$NIXOS_CONFIG" 2>/dev/null | sed -n '/nixosConfigurations/,$p' | sed -n '1,200p' || true
    ;;
  flake-show)
    preflight
    (cd "$NIXOS_CONFIG" && $NIX flake show)
    ;;
  flake-check)
    preflight
    (cd "$NIXOS_CONFIG" && $NIX flake check)
    ;;
  update-flake)
    preflight
    (cd "$NIXOS_CONFIG" && $NIX flake update)
    ;;
  fmt)
    preflight
    (cd "$NIXOS_CONFIG" && (nix fmt || nix run nixpkgs#nixpkgs-fmt -- .))
    ;;
  current-system)
    preflight
    current_system
    ;;
  list-generations)
    preflight
    list_generations
    ;;
  dry-build)
    preflight
    require_flake_host
    print_cmd build "--dry-run"
    run_rebuild build "--dry-run"
    ;;
  dry-switch)
    preflight
    require_flake_host
    print_cmd switch "--dry-run"
    run_rebuild switch "--dry-run"
    ;;
  build)
    preflight
    require_flake_host
    maybe_update_flake
    maybe_git_commit
    echo "Before:"
    current_system
    print_cmd build ""
    run_rebuild build ""
    echo "After:"
    current_system
    list_generations
    ;;
  switch)
    preflight
    require_flake_host
    maybe_update_flake
    maybe_git_commit
    echo "Before:"
    current_system
    print_cmd switch ""
    run_rebuild switch ""
    echo "After:"
    current_system
    list_generations
    ;;
  build-debug)
    preflight
    require_flake_host
    maybe_update_flake
    maybe_git_commit
    print_cmd switch "--verbose --show-trace"
    run_rebuild switch "--verbose --show-trace" | tee "$DEBUG_LOG"
    echo "Saved log: $DEBUG_LOG"
    ;;
  rollback)
    preflight
    $SUDO nixos-rebuild switch --rollback
    list_generations
    ;;
  gc)
    preflight
    $SUDO nix-collect-garbage
    ;;
  gc-hard)
    preflight
    $SUDO nix-collect-garbage -d --delete-older-than 1d
    ;;
  *)
    echo "Unknown command: ${1:-}"
    echo "Try: make help"
    exit 1
    ;;
esac
EOF
	@chmod +x "$(SCRIPT)"
	@echo "Generated $(SCRIPT)"

doctor: gen
	@"$(BASH)" "$(SCRIPT)" doctor

hosts: gen
	@"$(BASH)" "$(SCRIPT)" hosts

flake-show: gen
	@"$(BASH)" "$(SCRIPT)" flake-show

flake-check: gen
	@"$(BASH)" "$(SCRIPT)" flake-check

update-flake: gen
	@"$(BASH)" "$(SCRIPT)" update-flake

fmt: gen
	@"$(BASH)" "$(SCRIPT)" fmt

current-system: gen
	@"$(BASH)" "$(SCRIPT)" current-system

list-generations: gen
	@"$(BASH)" "$(SCRIPT)" list-generations

dry-build: gen
	@"$(BASH)" "$(SCRIPT)" dry-build

dry-switch: gen
	@"$(BASH)" "$(SCRIPT)" dry-switch

build: gen
	@"$(BASH)" "$(SCRIPT)" build

switch: gen
	@"$(BASH)" "$(SCRIPT)" switch

build-debug: gen
	@"$(BASH)" "$(SCRIPT)" build-debug

rollback: gen
	@"$(BASH)" "$(SCRIPT)" rollback

gc: gen
	@"$(BASH)" "$(SCRIPT)" gc

gc-hard: gen
	@"$(BASH)" "$(SCRIPT)" gc-hard