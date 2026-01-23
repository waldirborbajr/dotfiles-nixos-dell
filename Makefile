# ==========================================
# NixOS Infra Makefile — Borba (SAFE / STABLE)
# ==========================================

NIXOS_CONFIG ?= $(HOME)/nixos-config
HOST ?=

# Feature flags (independentes)
DEVOPS ?= 0
QEMU   ?= 0
IMPURE ?= 0

DEBUG_LOG ?= /tmp/nixos-build-debug.log

GIT_COMMIT_MSG ?= chore: auto-commit before rebuild
GIT_PUSH ?= 0

# --impure automaticamente quando necessário
NEED_IMPURE :=
ifeq ($(IMPURE),1)
  NEED_IMPURE := --impure
endif
ifeq ($(DEVOPS),1)
  NEED_IMPURE := --impure
endif
ifeq ($(QEMU),1)
  NEED_IMPURE := --impure
endif

# ==========================================
# Helpers
# ==========================================
.PHONY: require-host require-flake-host

require-host:
	@if [ -z "$(HOST)" ]; then \
		echo "ERROR: HOST is required. Example:"; \
		echo "  make switch HOST=macbook"; \
		exit 1; \
	fi

require-flake-host: require-host
	@echo "Validating flake host: $(HOST)"
	@if ! nix eval --raw "$(NIXOS_CONFIG)#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath" >/dev/null 2>&1; then \
		echo "ERROR: Host '$(HOST)' not found in flake."; \
		echo "Run: nix flake show $(NIXOS_CONFIG)"; \
		exit 1; \
	fi

# ==========================================
# Diagnostics
# ==========================================
.PHONY: help flake-show debug-cmd

help:
	@echo ""
	@echo "Usage:"
	@echo "  make switch HOST=macbook"
	@echo "  DEVOPS=1 make switch HOST=macbook"
	@echo "  QEMU=1 make switch HOST=macbook"
	@echo "  DEVOPS=1 QEMU=1 make switch HOST=macbook"
	@echo ""
	@echo "Flatpak:"
	@echo "  make flatpak-sync"
	@echo ""

flake-show:
	@cd $(NIXOS_CONFIG) && nix flake show

debug-cmd: require-flake-host
	@echo "Resolved command:"
	@echo "DEVOPS=$(DEVOPS) QEMU=$(QEMU) sudo nixos-rebuild switch --flake $(NIXOS_CONFIG)#$(HOST) $(NEED_IMPURE)"

# ==========================================
# Git / Flake
# ==========================================
.PHONY: update-flake check-git

update-flake:
	@echo "Updating flake..."
	@cd $(NIXOS_CONFIG) && nix flake update

check-git:
	@cd $(NIXOS_CONFIG) && \
	if [ -n "$$(git status --porcelain)" ]; then \
		echo "Git dirty → auto commit"; \
		git add .; \
		git commit -m "$(GIT_COMMIT_MSG)" || true; \
		if [ "$(GIT_PUSH)" = "1" ]; then git push; fi; \
	else \
		echo "Git clean"; \
	fi

# ==========================================
# Build / Switch
# ==========================================
.PHONY: build switch switch-safe upgrade rollback

build: require-flake-host
	$(MAKE) update-flake
	$(MAKE) check-git
	@echo ">>> nixos-rebuild build"
	@DEVOPS=$(DEVOPS) QEMU=$(QEMU) sudo nixos-rebuild build \
		--flake $(NIXOS_CONFIG)#$(HOST) $(NEED_IMPURE)

switch: require-flake-host
	$(MAKE) update-flake
	$(MAKE) check-git
	@echo ">>> nixos-rebuild switch"
	@DEVOPS=$(DEVOPS) QEMU=$(QEMU) sudo nixos-rebuild switch \
		--flake $(NIXOS_CONFIG)#$(HOST) $(NEED_IMPURE)
	$(MAKE) post-info

switch-safe: require-flake-host
	@sudo systemctl isolate multi-user.target
	@DEVOPS=$(DEVOPS) QEMU=$(QEMU) sudo nixos-rebuild switch \
		--flake $(NIXOS_CONFIG)#$(HOST) $(NEED_IMPURE)
	@sudo systemctl isolate graphical.target
	$(MAKE) post-info

upgrade: switch

rollback:
	@sudo nixos-rebuild switch --rollback
	$(MAKE) post-info

# ==========================================
# Post info
# ==========================================
.PHONY: post-info

post-info:
	@echo ""
	@echo "=== System Info ==="
	@echo "Host:    $(HOST)"
	@echo "DEVOPS:  $(DEVOPS)"
	@echo "QEMU:    $(QEMU)"
	@echo "Impure:  $(NEED_IMPURE)"
	@echo "Kernel:  $$(uname -r)"
	@echo "Uptime:  $$(uptime -p || true)"
	@echo "Gen:"
	@sudo nix-env -p /nix/var/nix/profiles/system --list-generations | grep current || true
	@echo "==================="

# ==========================================
# Maintenance
# ==========================================
.PHONY: gc gc-hard

gc:
	sudo nix-collect-garbage

gc-hard:
	sudo nix-collect-garbage -d --delete-older-than 1d

# ==========================================
# Flatpak (ISOLATED — NEVER DURING REBUILD)
# ==========================================
.PHONY: flatpak-sync

flatpak-sync:
	@bash -eu -o pipefail -c '\
	  echo "Flatpak sync..."; \
	  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true; \
	  FILE="$(NIXOS_CONFIG)/modules/flatpak/packages.nix"; \
	  apps=$$(grep -oE "\"[a-zA-Z0-9._-]+\"" "$$FILE" | tr -d "\"" | sort -u); \
	  installed=$$(flatpak list --app --columns=application || true); \
	  for app in $$apps; do \
	    if ! echo "$$installed" | grep -qx "$$app"; then \
	      echo "Installing $$app"; \
	      flatpak install -y flathub "$$app" || true; \
	    fi; \
	  done; \
	  flatpak update -y || true; \
	  flatpak uninstall --unused -y || true; \
	  echo "Flatpak sync done."; \
	'
