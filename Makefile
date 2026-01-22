# ==========================================
# NixOS Infra Makefile (with optional flakes)
# ==========================================

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=   # Ex: macbook ou dell

.PHONY: help build switch switch-off upgrade gc gc-hard fmt status flatpak-update

help:
	@echo "NixOS Infra Commands (flakes optional)"
	@echo ""
	@echo "  make build [HOST=host]      -> nixos-rebuild build"
	@echo "  make switch [HOST=host]     -> rebuild keeping graphical session"
	@echo "  make switch-off [HOST=host] -> rebuild in multi-user.target (safe)"
	@echo "  make upgrade [HOST=host]    -> rebuild with channel upgrade"
	@echo "  make gc                           -> nix garbage collection"
	@echo "  make gc-hard                      -> aggressive garbage collection"
	@echo "  make fmt                           -> format nix files"
	@echo "  make status                        -> systemd user jobs"
	@echo "  make flatpak-update                -> update all flatpaks"

# ------------------------------------------
# Internal command to handle flakes
# ------------------------------------------
NIXOS_CMD = sudo nixos-rebuild $(1) $(if $(HOST),--flake $(NIXOS_CONFIG)#$(HOST),-I nixos-config=$(NIXOS_CONFIG))

# ------------------------------------------
# Build only (no activation)
# ------------------------------------------
build:
	$(call NIXOS_CMD,build)

# ------------------------------------------
# Normal rebuild (graphical session)
# ------------------------------------------
switch:
	$(call NIXOS_CMD,switch)

# ------------------------------------------
# Safe rebuild (drop to multi-user.target)
# ------------------------------------------
switch-off:
	sudo systemctl isolate multi-user.target
	$(call NIXOS_CMD,switch)
	sudo systemctl isolate graphical.target

# ------------------------------------------
# Upgrade system (channels)
# ------------------------------------------
upgrade:
	sudo nix-channel --update
	$(call NIXOS_CMD,switch)

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
