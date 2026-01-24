# ==========================================
# NixOS Infra Makefile (Borba - NixGuru edition)
# Goals:
# - idiot-proof UX (clear errors, safe defaults)
# - reproducible + debuggable
# - keep existing behavior (DEVOPS/QEMU/IMPURE flags, auto-commit support)
# ==========================================

SHELL := /usr/bin/env
.ONESHELL:
.SHELLFLAGS := bash -euo pipefail -c

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=
IMPURE ?=
DEVOPS ?=
QEMU ?=
DEBUG_LOG ?= /tmp/nixos-build-debug.log

GIT_COMMIT_MSG ?= chore: auto-commit before rebuild
GIT_PUSH ?=

# Safety toggles
CONFIRM ?=
AUTO_UPDATE_FLAKE ?= 0   # 0 = safer default; set to 1 if you really want auto update
AUTO_GIT_COMMIT ?= 1     # keep your current behavior as default

# ------------------------------------------
# Internal helpers (shell-safe)
# ------------------------------------------
define die
	@echo "ERROR: $(1)" >&2
	@exit 1
endef

define require_host
	@if [[ -z "$(HOST)" ]]; then \
		echo "ERROR: HOST is required."; \
		echo "HINT: make hosts   # list available hosts"; \
		echo "EX:   make switch HOST=macbook"; \
		exit 1; \
	fi
endef

define require_repo
	@if [[ ! -e "$(NIXOS_CONFIG)/flake.nix" ]]; then \
		echo "ERROR: flake.nix not found in: $(NIXOS_CONFIG)"; \
		echo "HINT: set NIXOS_CONFIG=/path/to/nixos-config"; \
		exit 1; \
	fi
endef

define require_nix
	@if ! command -v nix >/dev/null 2>&1; then \
		echo "ERROR: nix command not found."; \
		echo "HINT: install Nix / NixOS tools first."; \
		exit 1; \
	fi
endef

define require_flakes
	@if ! nix --extra-experimental-features "nix-command flakes" flake show "$(NIXOS_CONFIG)" >/dev/null 2>&1; then \
		echo "ERROR: flakes not working or flake is invalid."; \
		echo "HINT: try: nix --extra-experimental-features \"nix-command flakes\" flake show $(NIXOS_CONFIG)"; \
		exit 1; \
	fi
endef

define require_sudo
	@if ! sudo -n true >/dev/null 2>&1; then \
		echo "INFO: sudo password may be required."; \
	fi
endef

define require_flake_host
	@echo "Validating flake host: $(HOST) in $(NIXOS_CONFIG)..."
	@if ! nix --extra-experimental-features "nix-command flakes" eval --raw \
		"$(NIXOS_CONFIG)#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath" \
		>/dev/null 2>&1; then \
		echo "ERROR: HOST='$(HOST)' not found in flake outputs."; \
		echo "HINT: make hosts"; \
		exit 1; \
	fi
endef

define show_flags
	@echo "Flags: HOST=$(HOST) IMPURE=$(IMPURE) DEVOPS=$(DEVOPS) QEMU=$(QEMU)"
endef

# ------------------------------------------
# nixos-rebuild command wrappers
# ------------------------------------------
define nixos_cmd
	$(if $(DEVOPS),DEVOPS=1,) \
	$(if $(QEMU),QEMU=1,) \
	sudo nixos-rebuild $(1) \
	--flake $(NIXOS_CONFIG)#$(HOST) \
	$(if $(IMPURE),--impure,) $(2)
endef

define print_cmd
	@echo ">>> nixos-rebuild command:"
	@echo "    $(if $(DEVOPS),DEVOPS=1,)$(if $(QEMU),QEMU=1,)sudo nixos-rebuild $(1) --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure,) $(2)"
endef

# ------------------------------------------
# Default target
# ------------------------------------------
.DEFAULT_GOAL := help

.PHONY: \
	help hosts flake-show doctor \
	preflight flake-check eval-host \
	update-flake check_git_status \
	build switch switch-off upgrade rollback \
	build-debug dry-switch dry-build \
	list-generations current-system why-no-new-generation \
	fmt status \
	gc gc-hard \
	flatpak-setup flatpak-update flatpak-update-repo

# ------------------------------------------
# Help
# ------------------------------------------
help:
	@echo "NixOS Infrastructure Commands (flakes) — NixGuru Edition"
	@echo ""
	@echo "Start here:"
	@echo "  make hosts"
	@echo "  make doctor"
	@echo ""
	@echo "Build/Switch:"
	@echo "  make build  HOST=<host> [DEVOPS=1] [QEMU=1] [IMPURE=1]"
	@echo "  make switch HOST=<host> [DEVOPS=1] [QEMU=1] [IMPURE=1]"
	@echo "  make dry-switch HOST=<host>   # shows what would happen"
	@echo ""
	@echo "Upgrade (updates flake.lock):"
	@echo "  make upgrade HOST=<host>"
	@echo ""
	@echo "Maintenance:"
	@echo "  make fmt"
	@echo "  make list-generations"
	@echo "  make current-system"
	@echo "  make rollback CONFIRM=YES"
	@echo "  make gc | make gc-hard CONFIRM=YES"
	@echo ""
	@echo "Notes:"
	@echo "  - AUTO_UPDATE_FLAKE=0 by default (safer)."
	@echo "  - AUTO_GIT_COMMIT=1 by default."

# ------------------------------------------
# Discovery / Diagnostics
# ------------------------------------------
hosts:
	@$(call require_repo)
	@echo "Available hosts from flake outputs:"
	@cd $(NIXOS_CONFIG) && nix --extra-experimental-features "nix-command flakes" flake show --json \
		| jq -r '.nixosConfigurations | keys[]' 2>/dev/null || \
		(echo "HINT: install jq for pretty host listing, or run: make flake-show"; exit 0)

flake-show:
	@$(call require_repo)
	@cd $(NIXOS_CONFIG) && nix --extra-experimental-features "nix-command flakes" flake show

doctor:
	@$(call require_repo)
	@$(call require_nix)
	@$(call require_flakes)
	@echo "OK: repo + nix + flakes look good."
	@echo "Repo: $(NIXOS_CONFIG)"
	@echo "Tip: make hosts"

# ------------------------------------------
# Preflight (fast-fail)
# ------------------------------------------
preflight:
	@$(call require_repo)
	@$(call require_nix)
	@$(call require_flakes)
	@$(call require_sudo)
	@$(call require_host)
	@$(call require_flake_host)
	@$(call show_flags)

flake-check:
	@$(call require_repo)
	@echo "Running flake check (fast sanity)..."
	@cd $(NIXOS_CONFIG) && nix --extra-experimental-features "nix-command flakes" flake check

eval-host:
	@$(call require_repo)
	@$(call require_host)
	@$(call require_flake_host)
	@echo "Evaluating toplevel drvPath for host $(HOST)..."
	@cd $(NIXOS_CONFIG) && nix --extra-experimental-features "nix-command flakes" eval --raw \
		".#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath"

# ------------------------------------------
# Update flake (explicit)
# ------------------------------------------
update-flake:
	@$(call require_repo)
	@echo "Updating flake.lock in $(NIXOS_CONFIG)..."
	@cd $(NIXOS_CONFIG) && nix --extra-experimental-features "nix-command flakes" flake update

# ------------------------------------------
# Git auto-commit (optional)
# ------------------------------------------
check_git_status:
	@$(call require_repo)
	@echo "Checking Git status in $(NIXOS_CONFIG)..."
	@if [[ "$(AUTO_GIT_COMMIT)" != "1" ]]; then \
		echo "AUTO_GIT_COMMIT=0 -> skipping auto-commit."; \
		exit 0; \
	fi
	@if [ -n "$$(git -C $(NIXOS_CONFIG) status --porcelain)" ]; then \
		echo "Git changes detected -> auto add/commit..."; \
		git -C $(NIXOS_CONFIG) add .; \
		git -C $(NIXOS_CONFIG) commit -m "$(GIT_COMMIT_MSG)" || true; \
		if [ "$(GIT_PUSH)" = "1" ]; then \
			git -C $(NIXOS_CONFIG) push; \
		fi; \
	else \
		echo "No git changes detected."; \
	fi

# ------------------------------------------
# Generations / System pointers
# ------------------------------------------
list-generations:
	@echo ""
	@sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 30

current-system:
	@echo "Current system -> $$(readlink -f /run/current-system)"
	@echo "System profile -> $$(readlink -f /nix/var/nix/profiles/system)"

why-no-new-generation:
	@echo "If generations don't advance, one of these is true:"
	@echo "  1) build output is identical (toplevel didn't change)"
	@echo "  2) your module isn't imported for this host"
	@echo "  3) rebuild failed before activation"
	@echo ""
	@echo "Current pointers:"
	@$(MAKE) current-system
	@echo ""
	@echo "Recent generations:"
	@$(MAKE) list-generations

# ------------------------------------------
# Format (flake formatter with fallback)
# ------------------------------------------
fmt:
	@$(call require_repo)
	@echo "Formatting Nix files..."
	@cd $(NIXOS_CONFIG) && (nix fmt || nix run nixpkgs#nixpkgs-fmt -- .)
	@git -C $(NIXOS_CONFIG) status

# ------------------------------------------
# Build / Switch (safe + observable)
# ------------------------------------------
dry-switch:
	@$(MAKE) preflight
	@$(call print_cmd,switch,--dry-run)
	@$(call nixos_cmd,switch,--dry-run)

dry-build:
	@$(MAKE) preflight
	@$(call print_cmd,build,--dry-run)
	@$(call nixos_cmd,build,--dry-run)

build:
	@$(MAKE) preflight
	@if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update."; fi
	@$(MAKE) check_git_status
	@$(MAKE) flake-check
	@echo "Before:"
	@$(MAKE) current-system
	@$(call print_cmd,build,)
	@$(call nixos_cmd,build,)
	@echo "After:"
	@$(MAKE) current-system
	@$(MAKE) list-generations

switch:
	@$(MAKE) preflight
	@if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update."; fi
	@$(MAKE) check_git_status
	@$(MAKE) flake-check
	@echo "Before:"
	@$(MAKE) current-system
	@$(call print_cmd,switch,)
	@$(call nixos_cmd,switch,)
	@echo "After:"
	@$(MAKE) current-system
	@$(MAKE) list-generations

switch-off:
	@$(MAKE) preflight
	@sudo systemctl isolate multi-user.target
	@$(call nixos_cmd,switch,)
	@sudo systemctl isolate graphical.target

upgrade:
	@$(MAKE) preflight
	@$(MAKE) update-flake
	@$(MAKE) check_git_status
	@$(MAKE) flake-check
	@$(call print_cmd,switch,)
	@$(call nixos_cmd,switch,)
	@$(MAKE) list-generations

build-debug:
	@$(MAKE) preflight
	@if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update."; fi
	@$(MAKE) check_git_status
	@$(call print_cmd,switch,--verbose --show-trace)
	@$(call nixos_cmd,switch,--verbose --show-trace) | tee $(DEBUG_LOG)
	@echo "Saved log: $(DEBUG_LOG)"

rollback:
	@if [[ "$(CONFIRM)" != "YES" ]]; then \
		echo "Refusing to rollback without explicit confirmation."; \
		echo "Run: make rollback CONFIRM=YES"; \
		exit 1; \
	fi
	@sudo nixos-rebuild switch --rollback
	@$(MAKE) list-generations

# ------------------------------------------
# Maintenance
# ------------------------------------------
gc:
	@sudo nix-collect-garbage

gc-hard:
	@if [[ "$(CONFIRM)" != "YES" ]]; then \
		echo "Refusing to run destructive GC without explicit confirmation."; \
		echo "Run: make gc-hard CONFIRM=YES"; \
		exit 1; \
	fi
	@sudo nix-collect-garbage -d --delete-older-than 1d

status:
	@systemctl --user list-jobs

# ------------------------------------------
# Flatpak
# ------------------------------------------
flatpak-setup:
	@flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak-update:
	@flatpak update -y

flatpak-update-repo:
	@flatpak update --appstream -y && flatpak update -y