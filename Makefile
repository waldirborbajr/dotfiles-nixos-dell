# ==========================================
# NixOS Infra Makefile (Borba - complete & hardened)
# - Always uses flake selector: $(NIXOS_CONFIG)#$(HOST)   (NO quotes to avoid truncation)
# - Validates HOST exists in nixosConfigurations.<HOST>
# - Flake update before build/switch
# - Auto add/commit to avoid dirty warnings/errors
# - Optional git push
# - List generations after operations
# - Post-build validation info
# - Flatpak Flathub remote setup + flatpak-sync (manual)
# ==========================================

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=                 # Example: macbook or dell
IMPURE ?=               # Set to 1 to add --impure
DEBUG_LOG ?= /tmp/nixos-build-debug.log

GIT_COMMIT_MSG ?= chore: auto-commit before rebuild
GIT_PUSH ?=             # Set to 1 to push after auto-commit

# Flatpak sync script (manual run)
FLATPAK_SYNC_SCRIPT ?= $(NIXOS_CONFIG)/scripts/flatpak-sync.sh

# ------------------------------------------
# Internal helpers
# ------------------------------------------
define require_host
	@if [ -z "$(HOST)" ]; then \
		echo "ERROR: HOST is required. Example: make switch HOST=macbook"; \
		exit 1; \
	fi
endef

define require_flake_host
	@echo "Validating flake host: $(HOST) in $(NIXOS_CONFIG)..."; \
	if ! nix --extra-experimental-features "nix-command flakes" eval --raw "$(NIXOS_CONFIG)#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath" >/dev/null 2>&1; then \
		echo "ERROR: HOST='$(HOST)' not found or not evaluatable in flake outputs (nixosConfigurations.$(HOST))."; \
		echo "HINT: Run: nix flake show $(NIXOS_CONFIG)"; \
		exit 1; \
	fi
endef

# nixos-rebuild command (flake-based)
# Usage: $(call NIXOS_CMD,<action>,<extra_args>)
# NOTE: We intentionally do NOT quote --flake to avoid line truncation in some shells/editors.
NIXOS_CMD = sudo nixos-rebuild $(1) --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure,) $(2)

define print_cmd
	@echo ">>> nixos-rebuild command:"
	@echo "    sudo nixos-rebuild $(1) --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure,) $(2)"
endef

define require_flatpak_script
	@if [ ! -f "$(FLATPAK_SYNC_SCRIPT)" ]; then \
		echo "ERROR: Flatpak sync script not found: $(FLATPAK_SYNC_SCRIPT)"; \
		echo "HINT: create it and chmod +x scripts/flatpak-sync.sh"; \
		exit 1; \
	fi
endef

.PHONY: \
	help update-flake check_git_status list-generations post-info \
	build build-debug switch switch-off upgrade rollback \
	gc gc-hard fmt status flatpak-setup flatpak-update flatpak-update-repo flatpak-sync \
	debug-cmd flake-show

# ------------------------------------------
# Help
# ------------------------------------------
help:
	@echo "NixOS Infrastructure Commands (flakes)"
	@echo ""
	@echo "Required:"
	@echo "  HOST=macbook | HOST=dell"
	@echo ""
	@echo "Common:"
	@echo "  make build HOST=<host>            -> flake update + auto-commit + nixos-rebuild build + list generations + post-info"
	@echo "  make switch HOST=<host>           -> flake update + auto-commit + nixos-rebuild switch + list generations + post-info"
	@echo "  make switch-off HOST=<host>       -> safe switch (multi-user.target) + list generations + post-info"
	@echo "  make upgrade HOST=<host>          -> flake update + auto-commit + switch + list generations + post-info"
	@echo "  make build-debug HOST=<host>      -> flake update + auto-commit + switch --verbose --show-trace (logs) + list generations + post-info"
	@echo ""
	@echo "Options:"
	@echo "  IMPURE=1                          -> adds --impure to nixos-rebuild"
	@echo "  GIT_PUSH=1                        -> pushes after auto-commit"
	@echo "  GIT_COMMIT_MSG='...'              -> commit message override"
	@echo "  DEBUG_LOG=/path/file.log          -> debug log path (build-debug)"
	@echo ""
	@echo "Diagnostics:"
	@echo "  make debug-cmd HOST=<host>        -> prints the resolved nixos-rebuild command"
	@echo "  make flake-show                   -> nix flake show (to see nixosConfigurations.*)"
	@echo ""
	@echo "Flatpak (manual):"
	@echo "  make flatpak-setup                -> add Flathub remote if missing"
	@echo "  make flatpak-sync                 -> run scripts/flatpak-sync.sh (install/update apps on-demand)"
	@echo "  make flatpak-update               -> flatpak update -y"
	@echo "  make flatpak-update-repo          -> flatpak update --appstream -y + update -y"
	@echo ""
	@echo "Maintenance:"
	@echo "  make gc                           -> nix garbage collection"
	@echo "  make gc-hard                      -> aggressive garbage collection"
	@echo "  make fmt                          -> nix fmt + git status"
	@echo "  make status                       -> systemd --user list-jobs"
	@echo "  make rollback                     -> nixos-rebuild switch --rollback + list generations + post-info"
	@echo ""
	@echo "Notes:"
	@echo "  - build/switch/upgrade/build-debug always run: nix flake update"
	@echo "  - auto-commit runs only if there are local changes"
	@echo "  - rollback is not per-HOST; it rolls back the currently booted machine"

# ------------------------------------------
# Diagnostics
# ------------------------------------------
flake-show:
	@cd $(NIXOS_CONFIG) && nix flake show

debug-cmd:
	@$(require_host)
	$(call print_cmd,switch,)

# ------------------------------------------
# Update flake (always before build/switch)
# ------------------------------------------
update-flake:
	@echo "Updating flake in $(NIXOS_CONFIG)..."
	@cd $(NIXOS_CONFIG) && nix flake update

# ------------------------------------------
# Auto add/commit (and optional push) to avoid dirty warnings/errors
# ------------------------------------------
check_git_status:
	@echo "Checking Git status in $(NIXOS_CONFIG)..."
	@if [ -n "$$(git -C $(NIXOS_CONFIG) status --porcelain)" ]; then \
		echo "Git changes detected -> auto add/commit..."; \
		git -C $(NIXOS_CONFIG) add .; \
		git -C $(NIXOS_CONFIG) commit -m "$(GIT_COMMIT_MSG)" || true; \
		if [ "$(GIT_PUSH)" = "1" ]; then \
			echo "Pushing changes..."; \
			git -C $(NIXOS_CONFIG) push; \
		fi; \
	else \
		echo "No git changes detected."; \
	fi

# ------------------------------------------
# List system generations
# ------------------------------------------
list-generations:
	@echo ""
	@echo "=== Current NixOS Generations ==="
	@sudo nix-env -p /nix/var/nix/profiles/system --list-generations
	@echo "================================="

# ------------------------------------------
# Post-build information (validation)
# ------------------------------------------
post-info:
	@echo ""
	@echo "=== Post-build validation ==="
	@echo "Host (flake):        $(HOST)"
	@echo "NixOS version:       $$(nixos-version)"
	@echo "Kernel:              $$(uname -r)"
	@echo "Uptime:              $$(uptime -p 2>/dev/null || true)"
	@echo "System store path:   $$(readlink /run/current-system)"
	@echo "Current generation:"
	@sudo nix-env -p /nix/var/nix/profiles/system --list-generations | grep current || true
	@echo "Desktop session (may be empty in TTY/build):"
	@echo "  XDG_CURRENT_DESKTOP=$$XDG_CURRENT_DESKTOP"
	@echo "  DESKTOP_SESSION=$$DESKTOP_SESSION"
	@echo "Finished at:         $$(date)"
	@echo "=============================="

# ------------------------------------------
# Build only (no activation)
# ------------------------------------------
build:
	@$(require_host)
	@$(require_flake_host)
	$(MAKE) update-flake
	$(MAKE) check_git_status
	$(call print_cmd,build,)
	$(call NIXOS_CMD,build,)
	$(MAKE) list-generations
	$(MAKE) post-info

# ------------------------------------------
# Switch (activate)
# ------------------------------------------
switch:
	@$(require_host)
	@$(require_flake_host)
	$(MAKE) update-flake
	$(MAKE) check_git_status
	@echo ">>> nixos-rebuild command:"
	@echo "    sudo nixos-rebuild switch --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure,)"
	sudo nixos-rebuild switch --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure,)
	$(MAKE) list-generations
	$(MAKE) post-info

# ------------------------------------------
# Safe switch (drop to multi-user.target)
# ------------------------------------------
switch-off:
	@$(require_host)
	@$(require_flake_host)
	$(MAKE) update-flake
	$(MAKE) check_git_status
	$(call print_cmd,switch,)
	sudo systemctl isolate multi-user.target
	$(call NIXOS_CMD,switch,)
	sudo systemctl isolate graphical.target
	$(MAKE) list-generations
	$(MAKE) post-info

# ------------------------------------------
# Upgrade system (flakes: update + switch)
# ------------------------------------------
upgrade:
	@$(require_host)
	@$(require_flake_host)
	$(MAKE) update-flake
	$(MAKE) check_git_status
	$(call print_cmd,switch,)
	$(call NIXOS_CMD,switch,)
	$(MAKE) list-generations
	$(MAKE) post-info

# ------------------------------------------
# Build-debug (verbose + show-trace)
# ------------------------------------------
build-debug:
	@$(require_host)
	@$(require_flake_host)
	$(MAKE) update-flake
	$(MAKE) check_git_status
	@echo "Starting build-debug for HOST=$(HOST), log at $(DEBUG_LOG)"
	$(call print_cmd,switch,--verbose --show-trace)
	$(call NIXOS_CMD,switch,--verbose --show-trace) 2>&1 | tee $(DEBUG_LOG)
	$(MAKE) list-generations
	$(MAKE) post-info

# ------------------------------------------
# Flatpak: ensure Flathub remote exists
# ------------------------------------------
flatpak-setup:
	@echo "Ensuring Flathub remote exists..."
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	@echo "Flathub remote is ready."

# Manual Flatpak sync (install/update apps on-demand)
flatpak-sync:
	@$(call require_flatpak_script)
	@echo "Running Flatpak sync script: $(FLATPAK_SYNC_SCRIPT)"
	@bash "$(FLATPAK_SYNC_SCRIPT)"

# ------------------------------------------
# Flatpak
# ------------------------------------------
flatpak-update:
	flatpak update -y

flatpak-update-repo:
	flatpak update --appstream -y
	flatpak update -y

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
	@cd $(NIXOS_CONFIG) && nix fmt
	@git -C $(NIXOS_CONFIG) status

# ------------------------------------------
# Debug helpers
# ------------------------------------------
status:
	systemctl --user list-jobs

# ------------------------------------------
# Rollback (current machine)
# ------------------------------------------
rollback:
	@echo "Rolling back to the previous system configuration..."
	sudo nixos-rebuild switch --rollback
	@echo "Rollback completed!"
	$(MAKE) list-generations
	$(MAKE) post-info
