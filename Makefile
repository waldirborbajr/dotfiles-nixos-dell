# =========================================================
# NixOS Makefile (non-flake, no Home Manager)
# =========================================================

# -------------------------
# Variables
# -------------------------
CONFIG_DIR ?= $(HOME)/nixos-config

# -------------------------
# Phony targets
# -------------------------
.PHONY: help switch build containers-docker containers-podman \
        rollback gc-soft gc-hard doctor

# -------------------------
# Help
# -------------------------
help:
	@echo ""
	@echo "NixOS Makefile targets:"
	@echo ""
	@echo "Build / Switch:"
	@echo "  switch             - Rebuild & switch"
	@echo "  build              - Build system (no switch)"
	@echo ""
	@echo "Containers:"
	@echo "  containers-docker  - Enable Docker (default)"
	@echo "  containers-podman  - Enable Podman (rootless)"
	@echo ""
	@echo "Maintenance:"
	@echo "  rollback           - Rollback to previous generation"
	@echo "  gc-soft            - Garbage collection (older than 7 days)"
	@echo "  gc-hard            - Aggressive garbage collection"
	@echo ""
	@echo "Diagnostics:"
	@echo "  doctor             - Sanity checks (nix, docker, podman, k3s, k9s)"
	@echo ""

# -------------------------
# Build / Switch
# -------------------------
build:
	sudo nixos-rebuild build -I nixos-config=$(CONFIG_DIR)/configuration.nix

switch:
	sudo nixos-rebuild switch -I nixos-config=$(CONFIG_DIR)/configuration.nix

# -------------------------
# Containers switch
# -------------------------
containers-docker:
	@echo ">> Enabling Docker (disabling Podman)..."
	@sed -i \
		-e 's|^# ./modules/containers/docker.nix|./modules/containers/docker.nix|' \
		-e 's|^./modules/containers/podman.nix|# ./modules/containers/podman.nix|' \
		$(CONFIG_DIR)/configuration.nix
	@echo ">> Docker enabled. Run: make switch"

containers-podman:
	@echo ">> Enabling Podman (disabling Docker)..."
	@sed -i \
		-e 's|^# ./modules/containers/podman.nix|./modules/containers/podman.nix|' \
		-e 's|^./modules/containers/docker.nix|# ./modules/containers/docker.nix|' \
		$(CONFIG_DIR)/configuration.nix
	@echo ">> Podman enabled. Run: make switch"

# ---------------------------------------------------------
# Maintenance
# ---------------------------------------------------------

rollback:
	sudo nixos-rebuild switch --rollback -I nixos-config=$(CONFIG_DIR)/configuration.nix

gc-soft:
	sudo nix-collect-garbage --delete-older-than 7d

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
