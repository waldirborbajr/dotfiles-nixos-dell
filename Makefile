# =========================================================
# NixOS Makefile (Flake-based, no Home Manager)
# =========================================================

# -------------------------
# Variables
# -------------------------
HOSTNAME ?= $(shell hostname)
FLAKE ?= .#$(HOSTNAME)
EXPERIMENTAL ?= --extra-experimental-features "nix-command flakes"

# -------------------------
# Phony targets
# -------------------------
.PHONY: help switch switch-impure build build-impure check update \
        rollback gc-soft gc-hard

# -------------------------
# Help
# -------------------------
help:
	@echo ""
	@echo "NixOS Makefile targets:"
	@echo ""
	@echo "  switch           - Rebuild & switch (pure flake)"
	@echo "  switch-impure    - Rebuild & switch (impure, uses host env)"
	@echo "  build            - Build system (pure, no switch)"
	@echo "  build-impure     - Build system (impure, no switch)"
	@echo "  check            - Run flake checks"
	@echo "  update           - Update flake inputs"
	@echo ""
	@echo "Maintenance:"
	@echo "  rollback         - Rollback to previous generation"
	@echo "  gc-soft          - Garbage collection (older than 7 days)"
	@echo "  gc-hard          - Aggressive garbage collection"
	@echo ""

# -------------------------
# Build / Switch
# -------------------------
switch:
	sudo nixos-rebuild switch --flake $(FLAKE)

switch-impure:
	sudo nixos-rebuild switch --flake $(FLAKE) --impure

build:
	nix build $(FLAKE)

build-impure:
	nix build $(FLAKE) --impure

# -------------------------
# Flake
# -------------------------
check:
	nix flake check

update:
	nix flake update

# ---------------------------------------------------------
# Maintenance
# ---------------------------------------------------------

## ↩️ Rollback system
rollback:
	sudo nixos-rebuild switch --rollback

## 🧹 Garbage collection (safe)
gc-soft:
	sudo nix-collect-garbage --delete-older-than 7d

## 💣 Garbage collection (aggressive)
gc-hard:
	sudo nix-collect-garbage -d
	sudo nix-store --gc
