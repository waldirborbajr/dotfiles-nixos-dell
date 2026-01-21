# ==========================================
# NixOS Infra Makefile
# ==========================================

FLAKE ?= .
HOST  ?= caveos
NIXOS_CONFIG ?= $(HOME)/nixos-config

.PHONY: help build switch switch-off upgrade gc gc-hard fmt status

help:
	@echo "NixOS Infra Commands"
	@echo ""
	@echo "  make build        -> nixos-rebuild build"
	@echo "  make switch       -> rebuild keeping graphical session"
	@echo "  make switch-off   -> rebuild in multi-user.target (safe)"
	@echo "  make upgrade      -> rebuild with --upgrade"
	@echo "  make gc           -> nix garbage collection"
	@echo "  make gc-hard      -> aggressive garbage collection"
	@echo "  make fmt          -> format nix files"
	@echo "  make status       -> systemd user jobs"

# ------------------------------------------
# Build only (no activation)
# ------------------------------------------
build:
	sudo nixos-rebuild build \
		--flake '$(FLAKE)#$(HOST)' \
		-I nixos-config=$(NIXOS_CONFIG)

# ------------------------------------------
# Normal rebuild (graphical session)
# ------------------------------------------
switch:
	sudo nixos-rebuild switch \
		--flake '$(FLAKE)#$(HOST)' \
		-I nixos-config=$(NIXOS_CONFIG)

# ------------------------------------------
# Safe rebuild (drop to multi-user.target)
# ------------------------------------------
switch-off:
	sudo systemctl isolate multi-user.target
	sudo nixos-rebuild switch \
		--flake '$(FLAKE)#$(HOST)' \
		-I nixos-config=$(NIXOS_CONFIG)
	sudo systemctl isolate graphical.target

# ------------------------------------------
# Upgrade system
# ------------------------------------------
upgrade:
	sudo nixos-rebuild switch \
		--upgrade \
		--flake '$(FLAKE)#$(HOST)' \
		-I nixos-config=$(NIXOS_CONFIG)

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
