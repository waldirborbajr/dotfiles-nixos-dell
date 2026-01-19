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
.PHONY: help \
        switch switch-impure build build-impure \
        check update \
        containers-docker containers-podman \
        rollback gc-soft gc-hard doctor

# -------------------------
# Help
# -------------------------
help:
	@echo ""
	@echo "NixOS Makefile targets:"
	@echo ""
	@echo "Build / Switch:"
	@echo "  switch             - Rebuild & switch (pure flake)"
	@echo "  switch-impure      - Rebuild & switch (impure)"
	@echo "  build              - Build system (pure, no switch)"
	@echo "  build-impure       - Build system (impure, no switch)"
	@echo ""
	@echo "Containers:"
	@echo "  containers-docker  - Enable Docker (default)"
	@echo "  containers-podman  - Enable Podman (rootless)"
	@echo ""
	@echo "Flake:"
	@echo "  check              - Run flake checks"
	@echo "  update             - Update flake inputs"
	@echo ""
	@echo "Maintenance:"
	@echo "  rollback           - Rollback to previous generation"
	@echo "  gc-soft            - Garbage collection (older than 7 days)"
	@echo "  gc-hard            - Aggressive garbage collection"
	@echo "  doctor             - Sanity checks"
	@echo ""

# -------------------------
# Build / Switch
# -------------------------
build:
	sudo nixos-rebuild switch

build-impure:
	sudo nixos-rebuild switch --impure

# -------------------------
# Containers switch
# -------------------------
containers-docker:
	@echo ">> Enabling Docker (disabling Podman)..."
	@sed -i \
		-e 's|^# ./modules/containers/docker.nix|./modules/containers/docker.nix|' \
		-e 's|^./modules/containers/podman.nix|# ./modules/containers/podman.nix|' \
		configuration.nix
	@echo ">> Docker enabled. Run: make switch"

containers-podman:
	@echo ">> Enabling Podman (disabling Docker)..."
	@sed -i \
		-e 's|^# ./modules/containers/podman.nix|./modules/containers/podman.nix|' \
		-e 's|^./modules/containers/docker.nix|# ./modules/containers/docker.nix|' \
		configuration.nix
	@echo ">> Podman enabled. Run: make switch"

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

# ---------------------------------------------------------
# Doctor (sanity checks)
# ---------------------------------------------------------
doctor:
	@echo ">> Running system sanity checks..."
	@command -v nix >/dev/null || echo "WARN: nix not found"
	@command -v nixos-rebuild >/dev/null || echo "WARN: nixos-rebuild not found"
	@command -v docker >/dev/null || echo "INFO: docker not installed"
	@command -v podman >/dev/null || echo "INFO: podman not installed"
	@command -v k3s >/dev/null || echo "INFO: k3s not installed"
	@command -v k9s >/dev/null || echo "INFO: k9s not installed"
	@echo ">> Doctor finished"
