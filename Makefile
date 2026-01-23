# ==========================================
# NixOS Infra Makefile (Borba - evolved, NOT regressed)
# - Adds DEVOPS=1 and QEMU=1 flags (independent)
# - Does NOT remove or change existing behavior
# ==========================================

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=
IMPURE ?=
DEVOPS ?=
QEMU ?=
DEBUG_LOG ?= /tmp/nixos-build-debug.log

GIT_COMMIT_MSG ?= chore: auto-commit before rebuild
GIT_PUSH ?=

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
	if ! nix --extra-experimental-features "nix-command flakes" eval --raw \
		"$(NIXOS_CONFIG)#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath" \
		>/dev/null 2>&1; then \
		echo "ERROR: HOST='$(HOST)' not found in flake outputs."; \
		echo "HINT: Run: nix flake show $(NIXOS_CONFIG)"; \
		exit 1; \
	fi
endef

# ------------------------------------------
# nixos-rebuild command
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
	@echo "    $(if $(DEVOPS),DEVOPS=1,)$(if $(QEMU),QEMU=1,) sudo nixos-rebuild $(1) --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure,) $(2)"
endef

.PHONY: \
	help update-flake check_git_status list-generations post-info \
	build switch switch-off upgrade rollback build-debug \
	gc gc-hard fmt status \
	flatpak-setup flatpak-update flatpak-update-repo \
	flake-show debug-cmd

# ------------------------------------------
# Help (UNCHANGED)
# ------------------------------------------
help:
	@echo "NixOS Infrastructure Commands (flakes)"
	@echo ""
	@echo "Required:"
	@echo "  HOST=macbook | HOST=dell"
	@echo ""
	@echo "Common:"
	@echo "  make build HOST=<host>"
	@echo "  make switch HOST=<host>"
	@echo "  make switch HOST=<host> DEVOPS=1"
	@echo "  make switch HOST=<host> QEMU=1"
	@echo "  make switch HOST=<host> DEVOPS=1 QEMU=1"
	@echo ""
	@echo "Options:"
	@echo "  IMPURE=1   -> adds --impure"
	@echo "  DEVOPS=1  -> enables docker/k3s (flake-controlled)"
	@echo "  QEMU=1    -> enables libvirt/qemu (flake-controlled)"
	@echo ""
	@echo "Maintenance:"
	@echo "  make gc | gc-hard | rollback | fmt | status"

# ------------------------------------------
# Diagnostics
# ------------------------------------------
flake-show:
	@cd $(NIXOS_CONFIG) && nix flake show

debug-cmd:
	@$(require_host)
	$(call print_cmd,switch,)

# ------------------------------------------
# Update flake
# ------------------------------------------
update-flake:
	@echo "Updating flake in $(NIXOS_CONFIG)..."
	@cd $(NIXOS_CONFIG) && nix flake update

# ------------------------------------------
# Git auto-commit
# ------------------------------------------
check_git_status:
	@echo "Checking Git status in $(NIXOS_CONFIG)..."
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
# Generations
# ------------------------------------------
list-generations:
	@echo ""
	@sudo nix-env -p /nix/var/nix/profiles/system --list-generations

post-info:
	@echo ""
	@echo "Host: $(HOST)"
	@echo "DEVOPS=$(DEVOPS) QEMU=$(QEMU)"
	@nixos-version
	@uname -r

# ------------------------------------------
# Build / Switch
# ------------------------------------------
build:
	@$(require_host)
	@$(require_flake_host)
	$(MAKE) update-flake
	$(MAKE) check_git_status
	$(call print_cmd,build,)
	$(call nixos_cmd,build,)
	$(MAKE) list-generations
	$(MAKE) post-info

switch:
	@$(require_host)
	@$(require_flake_host)
	$(MAKE) update-flake
	$(MAKE) check_git_status
	$(call print_cmd,switch,)
	$(call nixos_cmd,switch,)
	$(MAKE) list-generations
	$(MAKE) post-info

switch-off:
	@$(require_host)
	@$(require_flake_host)
	sudo systemctl isolate multi-user.target
	$(call nixos_cmd,switch,)
	sudo systemctl isolate graphical.target

upgrade:
	@$(require_host)
	$(MAKE) update-flake
	$(call nixos_cmd,switch,)

build-debug:
	@$(require_host)
	@$(require_flake_host)
	$(MAKE) update-flake
	$(call print_cmd,switch,--verbose --show-trace)
	$(call nixos_cmd,switch,--verbose --show-trace) | tee $(DEBUG_LOG)

# ------------------------------------------
# Maintenance
# ------------------------------------------
gc:
	sudo nix-collect-garbage

gc-hard:
	sudo nix-collect-garbage -d --delete-older-than 1d

fmt:
	@cd $(NIXOS_CONFIG) && nix fmt
	@git -C $(NIXOS_CONFIG) status

status:
	systemctl --user list-jobs

flatpak-setup:
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak-update:
	flatpak update -y

flatpak-update-repo:
	flatpak update --appstream -y && flatpak update -y

rollback:
	sudo nixos-rebuild switch --rollback
