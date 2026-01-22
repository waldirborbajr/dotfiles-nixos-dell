# ==========================================
# NixOS Infra Makefile definitivo
# ==========================================

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=   # Ex: macbook ou dell
DEBUG_LOG ?= /tmp/nixos-build-debug.log
GIT_COMMIT_MSG ?= chore: auto-commit before build-debug

.PHONY: help build build-debug switch switch-off upgrade gc gc-hard fmt status flatpak-update list-generations

.PHONY: help build switch switch-off upgrade gc gc-hard fmt status flatpak-update flatpak-update-repo rollback

# Help command
help:
	@echo "NixOS Infrastructure Commands (flakes optional)"
	@echo ""
	@echo "  make build [HOST=host]      -> Executes 'nixos-rebuild build' for the specified host"
	@echo "  make switch [HOST=host]     -> Rebuild keeping graphical session"
	@echo "  make switch-off [HOST=host] -> Rebuild in multi-user.target mode (safe)"
	@echo "  make upgrade [HOST=host]    -> Rebuild with channel upgrade"
	@echo "  make gc                     -> Garbage collection"
	@echo "  make gc-hard                -> Aggressive garbage collection (deletes older objects)"
	@echo "  make fmt                    -> Formats nix files and shows git status"
	@echo "  make status                 -> Shows active systemd user jobs"
	@echo "  make flatpak-update         -> Updates all Flatpak packages"
	@echo "  make flatpak-update-repo    -> Updates Flatpak repository information (from flatpak.org)"
	@echo "  make rollback               -> Rollback to previous system configuration"
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
update-flake:
	@echo "Updating flake..."
	nix flake update $(NIXOS_CONFIG)

# ------------------------------------------
# List system generations
# ------------------------------------------
list-generations:
	@echo ""
	@echo "=== Current NixOS Generations ==="
	sudo nix-env -p /nix/var/nix/profiles/system --list-generations
	@echo "================================="

# ------------------------------------------
# Build only (no activation)
# ------------------------------------------
build: update-flake check_git_status
	$(call NIXOS_CMD,build)
	$(MAKE) list-generations

# ------------------------------------------
# Build + switch with debug + auto Git commit
# ------------------------------------------
build-debug:
	@echo "Checking for git changes in $(NIXOS_CONFIG)..."
	@if [ -n "$$(git -C $(NIXOS_CONFIG) status --porcelain)" ]; then \
		echo "Git changes detected, committing automatically..."; \
		cd $(NIXOS_CONFIG) && git add . && git commit -m "$(GIT_COMMIT_MSG)"; \
	else \
		echo "No git changes detected."; \
	fi
	@echo "Starting build-debug for HOST=$(HOST), log at $(DEBUG_LOG)"
	@echo "Command: $(call NIXOS_CMD,switch --verbose --show-trace)"
	$(call NIXOS_CMD,switch --verbose --show-trace) 2>&1 | tee $(DEBUG_LOG)
	$(MAKE) list-generations

# ------------------------------------------
# Normal rebuild (keeping graphical session)
# ------------------------------------------
switch: update-flake check_git_status
	$(call NIXOS_CMD,switch)
	$(MAKE) list-generations

# ------------------------------------------
# Safe rebuild (drop to multi-user.target)
# ------------------------------------------
switch-off:
	# Isola em multi-user.target (sem interface gráfica)
	sudo systemctl isolate multi-user.target

	# Executa a reconstrução
	$(call NIXOS_CMD,switch)

	# Após a execução, retorna ao graphical.target (interface gráfica)
	sudo systemctl isolate graphical.target
	$(MAKE) list-generations

# ------------------------------------------
# Upgrade system (channels)
# ------------------------------------------
upgrade: update-flake check_git_status
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
# List systemd user jobs
# ------------------------------------------
status:
	systemctl --user list-jobs

# ------------------------------------------
# Flatpak update
# ------------------------------------------
flatpak-update:
	flatpak update -y

# ------------------------------------------
# Update Flatpak repository data from flatpak.org
# ------------------------------------------
flatpak-update-repo:
	flatpak update --appstream -y
	flatpak update -y

# ------------------------------------------
# Rollback to the previous configuration
# ------------------------------------------
rollback:
	@echo "Rolling back to the previous system configuration..."
	sudo nixos-rebuild switch --rollback
	@echo "Rollback completed!"
