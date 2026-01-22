# ==========================================
# NixOS Infra Makefile (flakes + debug + git commit + list generations)
# ==========================================

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=   # Ex: macbook ou dell
DEBUG_LOG ?= /tmp/nixos-build-debug.log
GIT_COMMIT_MSG ?= "chore: auto-commit before build-debug"

.PHONY: help build build-debug switch switch-off upgrade gc gc-hard fmt status flatpak-update

help:
	@echo "NixOS Infra Commands (flakes optional)"
	@echo ""
	@echo "  make build [HOST=host]        -> nixos-rebuild build + list generations"
	@echo "  make build-debug [HOST=host]  -> auto git commit + build + switch with verbose + show-trace + list generations"
	@echo "  make switch [HOST=host]       -> rebuild keeping graphical session + list generations"
	@echo "  make switch-off [HOST=host]   -> rebuild in multi-user.target (safe) + list generations"
	@echo "  make upgrade [HOST=host]      -> rebuild with channel upgrade + list generations"
	@echo "  make gc                        -> nix garbage collection"
	@echo "  make gc-hard                   -> aggressive garbage collection"
	@echo "  make fmt                        -> format nix files"
	@echo "  make status                     -> systemd user jobs"
	@echo "  make flatpak-update             -> update all flatpaks"

# ------------------------------------------
# Internal function to handle flakes
# ------------------------------------------
NIXOS_CMD = sudo nixos-rebuild $(1) $(if $(HOST),--flake $(NIXOS_CONFIG)#$(HOST),-I nixos-config=$(NIXOS_CONFIG))

# ------------------------------------------
# Internal helper to list generations
# ------------------------------------------
list-generations:
	@echo ""
	@echo "=== Current NixOS Generations ==="
	sudo nix-env -p /nix/var/nix/profiles/system --list-generations
	@echo "================================="

# ------------------------------------------
# Build only (no activation)
# ------------------------------------------
build:
	$(call NIXOS_CMD,build)
	$(MAKE) list-generations

# ------------------------------------------
# Build + switch with debug (verbose + show-trace + auto git commit)
# ------------------------------------------
build-debug:
	@echo "Checking for git changes in $(NIXOS_CONFIG)..."
	@if [ -n "$$(git -C $(NIXOS_CONFIG) status --porcelain)" ]; then \
		echo "Git changes detected, committing automatically..."; \
		git -C $(NIXOS_CONFIG) add .; \
		git -C $(NIXOS_CONFIG) commit -m "$(GIT_COMMIT_MSG)"; \
	else \
		echo "No git changes detected."; \
	fi
	@echo "Starting build-debug for HOST=$(HOST), log at $(DEBUG_LOG)"
	@echo "Command: $(call NIXOS_CMD,switch --verbose --show-trace)"
	$(call NIXOS_CMD,switch --verbose --show-trace) 2>&1 | tee $(DEBUG_LOG)
	$(MAKE) list-generations

# ------------------------------------------
# Normal rebuild (graphical session)
# ------------------------------------------
switch:
	$(call NIXOS_CMD,switch)
	$(MAKE) list-generations

# ------------------------------------------
# Safe rebuild (drop to multi-user.target)
# ------------------------------------------
switch-off:
	sudo systemctl isolate multi-user.target
	$(call NIXOS_CMD,switch)
	sudo systemctl isolate graphical.target
	$(MAKE) list-generations

# ------------------------------------------
# Upgrade system (channels)
# ------------------------------------------
upgrade:
	sudo nix-channel --update
	$(call NIXOS_CMD,switch)
	$(MAKE) list-generations

# ------------------------------------------
# Garbage collection
# ------------------------------------------
gc:
	sudo nix-collect-garbage

gc-hard:
	sudo nix-collect-garbage -d --delete-older-than 1d

# ------------------------------------------
# Formatting
# ------------------------------------------
fmt:
	nix fmt
	git status

# ------------------------------------------
# Debug helpers
# ------------------------------------------
status:
	systemctl --user list-jobs

# ------------------------------------------
# Flatpak update
# ------------------------------------------
flatpak-update:
	flatpak update -y
