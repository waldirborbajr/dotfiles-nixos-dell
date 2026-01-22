# ==========================================
# NixOS Infrastructure Makefile (with optional flakes and --impure flag)
# ==========================================

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=
IMPURE ?=

ifndef HOST
$(error HOST is required. Example: make switch HOST=macbook)
endif

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
	@echo "Notes:"
	@echo "  - Use 'HOST=macbook' or 'HOST=dell' to specify the host"
	@echo "  - For any other command, 'HOST' must be defined."
	@echo "  - The Makefile uses flakes to build the system for the specified host."
	@echo "  - The 'make upgrade' command updates the flake and the system"
	@echo "  - The 'make build' and 'make switch' now support an optional '--impure' flag to allow impure builds"
	@echo "  - The 'make flatpak-update-repo' command updates the Flatpak repository data from flatpak.org"
	@echo "  - For more details, refer to the documentation or the NixOS repository"

# ------------------------------------------
# Internal command to run flakes with optional --impure flag
# ------------------------------------------
NIXOS_CMD = sudo nixos-rebuild $(1) --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure)

# ------------------------------------------
# Function to check for uncommitted changes in Git
# ------------------------------------------
check_git_status:
	@echo "Checking Git status..."
	@if ! git diff --exit-code > /dev/null; then \
		echo "There are uncommitted changes, performing commit..."; \
		git add .; \
		git commit -m 'Auto commit before rebuild'; \
		git push; \
	else \
		echo "No uncommitted changes in the repository."; \
	fi

# ------------------------------------------
# Ensure flake is updated before build/switch
# ------------------------------------------
update-flake:
	@echo "Updating flake..."
	nix flake update $(NIXOS_CONFIG)

# ------------------------------------------
# Build only (no activation)
# ------------------------------------------
build: update-flake check_git_status
	$(call NIXOS_CMD,build)
	@echo "System rebuilt successfully!"
	@echo "System version: $(shell nixos-version)"
	@echo "Build finished at: $(shell date)"

# ------------------------------------------
# Normal rebuild (keeping graphical session)
# ------------------------------------------
switch: update-flake check_git_status
	$(call NIXOS_CMD,switch)
	@echo "System rebuilt and switched successfully!"
	@echo "System version: $(shell nixos-version)"
	@echo "Switch finished at: $(shell date)"

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

# ------------------------------------------
# Upgrade system (channels)
# ------------------------------------------
upgrade: update-flake check_git_status
	$(call NIXOS_CMD,switch)
	@echo "System upgraded successfully!"
	@echo "System version: $(shell nixos-version)"
	@echo "Upgrade finished at: $(shell date)"

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
