# =========================================================
# NixOS Maintenance Makefile
# Repo-based (no /etc/nixos, no flakes, no Home Manager)
# =========================================================

CONFIG_DIR ?= $(HOME)/nixos-config

.PHONY: help switch build rollback \
        channels gc-soft gc-hard optimise verify \
        doctor generations space \
        fmt lint ci

# ---------------------------------------------------------
# Help
# ---------------------------------------------------------
help:
	@echo ""
	@echo "NixOS Maintenance Makefile"
	@echo ""
	@echo "Build / Switch:"
	@echo "  make switch        - Rebuild & switch system"
	@echo "  make build         - Build system only"
	@echo "  make rollback      - Rollback to previous generation"
	@echo ""
	@echo "Lint / Format:"
	@echo "  make fmt           - Format all Nix files"
	@echo "  make lint          - Run all linters"
	@echo "  make ci            - Lint + build (CI target)"
	@echo ""
	@echo "Channels:"
	@echo "  make channels      - Update nix channels"
	@echo ""
	@echo "Garbage Collection:"
	@echo "  make gc-soft       - GC older than 7 days"
	@echo "  make gc-hard       - Full GC (delete all old generations)"
	@echo ""

# ---------------------------------------------------------
# Build / Switch
# ---------------------------------------------------------
build:
	sudo nixos-rebuild build \
		-I nixos-config=$(CONFIG_DIR)

switch:
	sudo nixos-rebuild switch \
		-I nixos-config=$(CONFIG_DIR)

rollback:
	sudo nixos-rebuild switch --rollback \
		-I nixos-config=$(CONFIG_DIR)

# ---------------------------------------------------------
# Format
# ---------------------------------------------------------
fmt:
	@echo ">> Formatting Nix files"
	find . -name "*.nix" \
	  ! -name "hardware-configuration-*.nix" \
	  -print0 \
	| xargs -0 nix run nixpkgs#nixfmt-rfc-style -- nixfmt

# ---------------------------------------------------------
# Lint
# ---------------------------------------------------------
lint:
	@echo ">> nixfmt check"
	find . -name "*.nix" \
	  ! -name "hardware-configuration-*.nix" \
	  -print0 \
	| xargs -0 nix run nixpkgs#nixfmt-rfc-style -- nixfmt --check

	@echo ">> statix"
	nix run nixpkgs#statix -- check .

	@echo ">> deadnix"
	nix run nixpkgs#deadnix -- \
	  --exclude hardware-configuration-dell.nix \
	  --exclude hardware-configuration-macbook.nix \
	  .

# ---------------------------------------------------------
# CI aggregate
# ---------------------------------------------------------
ci: lint build

# ---------------------------------------------------------
# Channels
# ---------------------------------------------------------
channels:
	@echo ">> Updating Nix channels..."
	sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable || true
	sudo nix-channel --update

# ---------------------------------------------------------
# Garbage Collection
# ---------------------------------------------------------
gc-soft:
	sudo nix-collect-garbage --delete-older-than 7d

gc-hard:
	sudo nix-collect-garbage -d

# ---------------------------------------------------------
# Store Maintenance
# ---------------------------------------------------------
optimise:
	sudo nix store optimise

verify:
	sudo nix-store --verify --check-contents

# ---------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------
generations:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

space:
	df -h /
	du -sh /nix/store

doctor:
	nix --version || true
	readlink /nix/var/nix/profiles/system
	systemctl list-timers | grep nix || true
	systemctl is-active docker || true
	systemctl is-active k3s || true
	du -sh /nix/store
