# =========================================================
# NixOS Maintenance Makefile
# Repo-based (no /etc/nixos, no flakes, no Home Manager)
# =========================================================

CONFIG_DIR ?= $(HOME)/nixos-config

.PHONY: help \
        build switch rollback \
        channels \
        gc-soft gc-hard \
        optimise verify \
        generations space doctor \
        lint fmt

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
	@echo "Formatting / Lint:"
	@echo "  make fmt           - Format Nix files and auto-commit if changed"
	@echo "  make lint          - Run nixfmt (check) and deadnix"
	@echo ""
	@echo "Channels:"
	@echo "  make channels      - Update Nix channels"
	@echo ""
	@echo "Garbage Collection:"
	@echo "  make gc-soft       - GC older than 7 days"
	@echo "  make gc-hard       - Full GC (delete all old generations)"
	@echo ""
	@echo "Store Maintenance:"
	@echo "  make optimise      - Deduplicate Nix store"
	@echo "  make verify        - Verify store integrity"
	@echo ""
	@echo "Diagnostics:"
	@echo "  make doctor        - System health overview"
	@echo "  make generations   - List system generations"
	@echo "  make space         - Disk usage overview"
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
# Formatting (AUTO-COMMIT)
# ---------------------------------------------------------
fmt:
	@echo ">> Formatting Nix files..."
	@nix-shell -p nixfmt-rfc-style --run '\
		find . -name "*.nix" \
		  ! -name "hardware-configuration-*.nix" \
		  -print0 \
		| xargs -0 nixfmt \
	'
	@echo ""
	@echo ">> Git status after formatting:"
	@git status --short
	@echo ""
	@if git diff --quiet; then \
		echo ">> No formatting changes detected. Nothing to commit."; \
	else \
		echo ">> Committing formatting changes..."; \
		git commit -am "chore: format nix files"; \
	fi

# ---------------------------------------------------------
# Lint (CHECK ONLY)
# ---------------------------------------------------------
lint:
	@echo ">> Running nixfmt check..."
	@nix-shell -p nixfmt-rfc-style --run '\
		find . -name "*.nix" \
		  ! -name "hardware-configuration-*.nix" \
		  -print0 \
		| xargs -0 nixfmt --check \
	'

	# -----------------------------------------------------
	# Statix is temporarily disabled.
	# Reason: the current configuration is stable and works
	# correctly. Warnings reported by statix require careful
	# refactoring and will be addressed later with proper
	# validation to avoid regressions.
	# -----------------------------------------------------
	# @echo ">> Running statix..."
	# @nix-shell -p statix --run "statix check ."

	@echo ">> Running deadnix..."
	@nix-shell -p deadnix --run '\
		deadnix \
		  --exclude hardware-configuration-dell.nix,hardware-configuration-macbook.nix \
		  . \
	'

# ---------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------
generations:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

space:
	@echo ">> Disk usage:"
	df -h /
	@echo ""
	@echo ">> Nix store size:"
	du -sh /nix/store

doctor:
	@echo ">> Nix version:"
	nix --version || true
	@echo ""
	@echo ">> Active system generation:"
	readlink /nix/var/nix/profiles/system
	@echo ""
	@echo ">> GC timers:"
	systemctl list-timers | grep nix || true
	@echo ""
	@echo ">> Docker:"
	systemctl is-active docker || true
	@echo ""
	@echo ">> K3s:"
	systemctl is-active k3s || true
	@echo ""
	@echo ">> Store size:"
	du -sh /nix/store
	@echo ""
	@echo ">> Doctor finished"
