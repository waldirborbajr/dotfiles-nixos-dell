# ==========================================
# NixOS Infra Makefile (Borba - NixGuru edition)
# Goals:
# - idiot-proof UX (clear errors, safe defaults)
# - reproducible + debuggable
# - auto-commit + push sempre para build/switch/switch-prod
# ==========================================
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=
IMPURE ?=
DEVOPS ?=
QEMU ?=
DEBUG_LOG ?= /tmp/nixos-build-debug.log

# Mensagem de commit dinâmica com data/hora
GIT_COMMIT_MSG := wip(makefile): $(shell date '+%Y-%m-%d %H:%M')
GIT_PUSH ?= 1  # Sempre tenta push (pode sobrescrever com GIT_PUSH=0)

# Safety toggles
CONFIRM ?=
AUTO_UPDATE_FLAKE ?= 0  # 0 = mais seguro (default)
AUTO_GIT_COMMIT ?= 1    # Sempre 1 agora (não precisa mais flag)

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
		echo "HINT: make hosts # list available hosts"; \
		echo "EX: make switch HOST=macbook"; \
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
	@echo "  $(if $(DEVOPS),DEVOPS=1 )$(if $(QEMU),QEMU=1 )sudo nixos-rebuild $(1) --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure,) $(2)"
endef

# ------------------------------------------
# Default target
# ------------------------------------------
.DEFAULT_GOAL := help
.PHONY: help hosts flake-show doctor preflight flake-check check eval-host \
	update-flake check_git_status \
	build test-build switch switch-prod switch-off upgrade rollback \
	dry-switch dry-build \
	build-debug \
	list-generations current-system why-no-new-generation \
	fmt status gc gc-hard

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
	@echo "Validation (sem aplicar mudanças):"
	@echo "  make check               # Verifica sintaxe do flake"
	@echo "  make test-build HOST=macbook [DEVOPS=1] [QEMU=1]  # Test build"
	@echo ""
	@echo "Build/Switch (com auto-commit + push automático):"
	@echo "  make build     HOST=macbook [DEVOPS=1] [QEMU=1] [IMPURE=1]"
	@echo "  make switch    HOST=macbook [DEVOPS=1] [QEMU=1] [IMPURE=1]"
	@echo "  make switch-prod HOST=macbook [DEVOPS=1] [QEMU=1] [IMPURE=1]"
	@echo ""
	@echo "Upgrade (atualiza flake.lock):"
	@echo "  make upgrade HOST=macbook"
	@echo ""
	@echo "Maintenance:"
	@echo "  make fmt"
	@echo "  make list-generations"
	@echo "  make rollback CONFIRM=YES"
	@echo "  make gc | make gc-hard CONFIRM=YES"
	@echo ""
	@echo "Notes:"
	@echo "  - AUTO_GIT_COMMIT=1 sempre (auto add/commit/push antes de rebuild)"
	@echo "  - Mensagem commit: wip(makefile): YYYY-MM-DD HH:MM"
	@echo "  - AUTO_UPDATE_FLAKE=0 por default (mais seguro)"

# ------------------------------------------
# Discovery / Diagnostics
# ------------------------------------------
hosts:
	@$(call require_repo)
	@echo "Available hosts from flake outputs:"
	@cd $(NIXOS_CONFIG) && nix --extra-experimental-features "nix-command flakes" flake show --json \
		| jq -r '.nixosConfigurations | keys[]' 2>/dev/null || \
		(echo "HINT: install jq for pretty listing, or run: make flake-show"; exit 0)

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

check:
	@$(call require_repo)
	@echo "Verificando sintaxe do flake com --impure..."
	@cd $(NIXOS_CONFIG) && nix --extra-experimental-features "nix-command flakes" flake check --impure
	@echo "✓ Sintaxe OK!"

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
# Git auto-commit + push (obrigatório para build/switch/switch-prod)
# ------------------------------------------
check_git_status:
	@$(call require_repo)
	@echo "Checking Git status in $(NIXOS_CONFIG)..."
	@if [ -z "$$(git -C $(NIXOS_CONFIG) status --porcelain)" ]; then \
		echo "Git tree clean. No changes."; \
	else \
		echo "Git changes detected → auto add / commit / push..."; \
		git -C $(NIXOS_CONFIG) add .; \
		git -C $(NIXOS_CONFIG) commit -m "$(GIT_COMMIT_MSG)" || { echo "Commit skipped (nothing new after add)"; true; }; \
		if [ "$(GIT_PUSH)" = "1" ]; then \
			git -C $(NIXOS_CONFIG) push origin main || { echo "Push falhou (pode ser auth/upstream). Continuando..."; true; }; \
		fi; \
	fi

# ------------------------------------------
# Build / Switch (com auto-commit + push)
# ------------------------------------------
dry-switch:
	@$(MAKE) preflight
	@$(call print_cmd,switch,--dry-run)
	@$(call nixos_cmd,switch,--dry-run)

dry-build:
	@$(MAKE) preflight
	@$(call print_cmd,build,--dry-run)
	@$(call nixos_cmd,build,--dry-run)

test-build:
	@$(MAKE) preflight
	@echo "Test build (não aplica mudanças) para host: $(HOST)"
	@$(call print_cmd,build,)
	@$(call nixos_cmd,build,)
	@echo "✓ Test build concluído! Nenhuma mudança foi aplicada."
	@echo "Para aplicar mudanças: make switch HOST=$(HOST)"

build:
	@$(MAKE) preflight
	@if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 → skipping flake update."; fi
	@$(MAKE) check_git_status
	@$(MAKE) flake-check
	@echo "Before:" && $(MAKE) current-system
	@$(call print_cmd,build,)
	@$(call nixos_cmd,build,)
	@echo "After:" && $(MAKE) current-system && $(MAKE) list-generations

switch:
	@$(MAKE) preflight
	@if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 → skipping flake update."; fi
	@$(MAKE) check_git_status
	@echo "Before:" && $(MAKE) current-system
	@$(call print_cmd,switch,)
	@$(call nixos_cmd,switch,)
	@echo "After:" && $(MAKE) current-system && $(MAKE) list-generations

switch-prod:
	@$(MAKE) preflight
	@if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 → skipping flake update."; fi
	@$(MAKE) check_git_status
	@$(MAKE) flake-check
	@echo "Before:" && $(MAKE) current-system
	@$(call print_cmd,switch,)
	@$(call nixos_cmd,switch,)
	@echo "After:" && $(MAKE) current-system && $(MAKE) list-generations

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
	@if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 → skipping flake update."; fi
	@$(MAKE) check_git_status
	@$(MAKE) flake-check
	@$(call print_cmd,switch,--verbose --show-trace)
	@$(call nixos_cmd,switch,--verbose --show-trace) | tee $(DEBUG_LOG)
	@echo "Saved log: $(DEBUG_LOG)"

# ------------------------------------------
# Generations / Rollback
# ------------------------------------------
list-generations:
	@echo ""
	@sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 30

current-system:
	@echo "Current system -> $$(readlink -f /run/current-system)"
	@echo "System profile -> $$(readlink -f /nix/var/nix/profiles/system)"

why-no-new-generation:
	@echo "If generations don't advance, one of these is true:"
	@echo " 1) build output is identical (toplevel didn't change)"
	@echo " 2) your module isn't imported for this host"
	@echo " 3) rebuild failed before activation"
	@echo ""
	@echo "Current pointers:" && $(MAKE) current-system
	@echo "" && echo "Recent generations:" && $(MAKE) list-generations

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
fmt:
	@$(call require_repo)
	@echo "Formatting Nix files..."
	@cd $(NIXOS_CONFIG) && (nix fmt || nix run nixpkgs#nixpkgs-fmt -- .)
	@git -C $(NIXOS_CONFIG) status

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
