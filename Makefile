# ==========================================
# NixOS Infra Makefile (Borba - Definitive / NixGuru)
# - RECIPEPREFIX to avoid TAB hell
# - Preflight + real nix errors
# - Auto-fix target to strip CRLF + bad indentation
# - Guard to prevent "missing separator" forever
# ==========================================

# ---- Make safety / UX ----
.RECIPEPREFIX := >
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

# ---- Config ----
# If you run make inside the repo, use it. Otherwise fall back.
NIXOS_CONFIG ?= $(if $(wildcard $(CURDIR)/flake.nix),$(CURDIR),$(HOME)/nixos-config)

HOST ?=
IMPURE ?=
DEVOPS ?=
QEMU ?=

AUTO_UPDATE_FLAKE ?= 0   # safer default (0). Set 1 to auto nix flake update.
AUTO_GIT_COMMIT ?= 1     # keep your behavior (1). Set 0 to disable.
GIT_COMMIT_MSG ?= chore: auto-commit before rebuild
GIT_PUSH ?=
DEBUG_LOG ?= /tmp/nixos-build-debug.log

# nix command with flakes enabled
NIX := nix --extra-experimental-features "nix-command flakes"

.PHONY: \
  help doctor hosts flake-show flake-check \
  fix-makefile guard-make \
  update-flake check_git_status \
  preflight \
  build switch dry-build dry-switch build-debug \
  current-system list-generations rollback \
  gc gc-hard fmt

# ------------------------------------------
# Helpers
# ------------------------------------------
define die
echo "ERROR: $(1)" >&2
exit 1
endef

define require_repo
[[ -f "$(NIXOS_CONFIG)/flake.nix" ]] || $(call die,flake.nix not found in '$(NIXOS_CONFIG)'. Set NIXOS_CONFIG=/path/to/nixos-config)
endef

define require_nix
command -v nix >/dev/null 2>&1 || $(call die,"nix command not found")
endef

define require_host
[[ -n "$(HOST)" ]] || ( \
  echo "ERROR: HOST is required."; \
  echo "HINT: make hosts"; \
  echo "EX:   make switch HOST=macbook"; \
  exit 1 \
)
endef

define show_flags
echo "Repo:  $(NIXOS_CONFIG)"
echo "Flags: HOST=$(HOST) IMPURE=$(IMPURE) DEVOPS=$(DEVOPS) QEMU=$(QEMU)"
endef

define nixos_cmd
$(if $(DEVOPS),DEVOPS=1,) \
$(if $(QEMU),QEMU=1,) \
sudo nixos-rebuild $(1) \
  --flake "$(NIXOS_CONFIG)#$(HOST)" \
  $(if $(IMPURE),--impure,) $(2)
endef

define print_cmd
echo ">>> $(if $(DEVOPS),DEVOPS=1,)$(if $(QEMU),QEMU=1,)sudo nixos-rebuild $(1) --flake $(NIXOS_CONFIG)#$(HOST) $(if $(IMPURE),--impure,) $(2)"
endef

# Print REAL nix eval errors (no lying "host not found")
define require_flake_host
echo "Validating host '$(HOST)' in flake outputs..."
if $(NIX) eval --raw "$(NIXOS_CONFIG)#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath" >/dev/null; then \
  echo "OK: host '$(HOST)' exists."; \
else \
  echo ""; \
  echo "Nix evaluation failed. Real error output:"; \
  echo "----------------------------------------"; \
  $(NIX) eval --raw "$(NIXOS_CONFIG)#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath"; \
  echo "----------------------------------------"; \
  echo ""; \
  echo "If it mentions missing outputs, run: make hosts"; \
  exit 1; \
fi
endef

define preflight_body
$(call require_repo)
$(call require_nix)
$(call require_host)
$(call show_flags)
$(call require_flake_host)
endef

# ------------------------------------------
# Anti-idiot guard (kills separator errors)
# ------------------------------------------
# This checks for any recipe lines that:
# - are inside a target (indented)
# - but do NOT start with '>' after optional whitespace
# If found: fail with line numbers.
guard-make:
> $(call require_repo)
> echo "Guard: checking Makefile recipe indentation..."
> awk '\
>   BEGIN{inrule=0} \
>   /^[^[:space:]].*:[[:space:]]*($$|#)/{inrule=1; next} \
>   inrule && /^[^[:space:]]/ {inrule=0} \
>   inrule && /^[[:space:]]+[^>#[:space:]]/ {print NR ": bad recipe line -> " $$0; bad=1} \
>   END{exit (bad?1:0)}' Makefile \
> || $(call die,"Makefile has recipe lines not starting with '>' (see lines above). Run: make fix-makefile")

# ------------------------------------------
# Auto-fix (strip CRLF + normalize recipe indent)
# ------------------------------------------
fix-makefile:
> echo "Fixing Makefile (CRLF + bad indentation) ..."
> # 1) Convert CRLF -> LF safely
> sed -i 's/\r$$//' Makefile
> # 2) For lines that start with whitespace then '>' -> remove whitespace before '>'
> sed -i 's/^[[:space:]]\+>/>/g' Makefile
> # 3) For lines that start with whitespace then '@' inside recipes (common mistake) -> force '>' prefix
> #    This won't change non-recipe lines; it's a best-effort safety net.
> #    If you really have a line beginning with spaces+@ in a non-recipe context (rare), remove it manually.
> sed -i 's/^[[:space:]]\+@/> @/g' Makefile
> echo "Done. Now run: make guard-make"

# ------------------------------------------
# UX
# ------------------------------------------
help:
> echo "NixOS Infra (flakes) — Definitive Makefile"
> echo ""
> echo "Start:"
> echo "  make fix-makefile   # strips CRLF + fixes indentation"
> echo "  make guard-make     # refuses to run if recipes are malformed"
> echo "  make doctor"
> echo "  make hosts"
> echo ""
> echo "Build/Switch:"
> echo "  make build  HOST=<host> [DEVOPS=1] [QEMU=1] [IMPURE=1]"
> echo "  make switch HOST=<host> [DEVOPS=1] [QEMU=1] [IMPURE=1]"
> echo "  make dry-switch HOST=<host>"
> echo ""
> echo "Optional:"
> echo "  AUTO_UPDATE_FLAKE=1 make switch HOST=macbook"
> echo ""
> echo "Maintenance:"
> echo "  make current-system | list-generations | rollback"
> echo "  make fmt | gc | gc-hard"

doctor:
> $(call require_repo)
> $(call require_nix)
> echo "OK: repo + nix present"
> echo "Repo: $(NIXOS_CONFIG)"
> echo "Next: make hosts"

hosts:
> $(call require_repo)
> echo "Available nixosConfigurations (best effort):"
> $(NIX) flake show "$(NIXOS_CONFIG)" 2>/dev/null | sed -n '/nixosConfigurations/,$$p' | sed -n '1,200p' || true
> echo ""
> echo "If you want machine-readable:"
> echo "  $(NIX) flake show --json $(NIXOS_CONFIG)"

flake-show:
> $(call require_repo)
> cd "$(NIXOS_CONFIG)"
> $(NIX) flake show

flake-check:
> $(call require_repo)
> cd "$(NIXOS_CONFIG)"
> $(NIX) flake check

# ------------------------------------------
# Git auto-commit
# ------------------------------------------
check_git_status:
> $(call require_repo)
> echo "Checking Git status..."
> if [[ "$(AUTO_GIT_COMMIT)" != "1" ]]; then
>   echo "AUTO_GIT_COMMIT=0 -> skipping auto-commit"
>   exit 0
> fi
> if [[ -n "$$(git -C "$(NIXOS_CONFIG)" status --porcelain)" ]]; then
>   echo "Git changes detected -> add/commit..."
>   git -C "$(NIXOS_CONFIG)" add .
>   git -C "$(NIXOS_CONFIG)" commit -m "$(GIT_COMMIT_MSG)" || true
>   if [[ "$(GIT_PUSH)" == "1" ]]; then
>     git -C "$(NIXOS_CONFIG)" push
>   fi
> else
>   echo "No git changes detected."
> fi

# ------------------------------------------
# Flake update
# ------------------------------------------
update-flake:
> $(call require_repo)
> echo "Updating flake.lock..."
> cd "$(NIXOS_CONFIG)"
> $(NIX) flake update

# ------------------------------------------
# Preflight
# ------------------------------------------
preflight:
> $(MAKE) guard-make
> $(preflight_body)

# ------------------------------------------
# System pointers / generations
# ------------------------------------------
current-system:
> echo "Current system: $$(readlink -f /run/current-system)"
> echo "Profile:        $$(readlink -f /nix/var/nix/profiles/system)"

list-generations:
> echo ""
> sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 60

# ------------------------------------------
# Build/Switch
# ------------------------------------------
dry-build:
> $(MAKE) preflight
> $(call print_cmd,build,--dry-run)
> $(call nixos_cmd,build,--dry-run)

dry-switch:
> $(MAKE) preflight
> $(call print_cmd,switch,--dry-run)
> $(call nixos_cmd,switch,--dry-run)

build:
> $(MAKE) preflight
> if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update"; fi
> $(MAKE) check_git_status
> echo "Before:"
> $(MAKE) current-system
> $(call print_cmd,build,)
> $(call nixos_cmd,build,)
> echo "After:"
> $(MAKE) current-system
> $(MAKE) list-generations

switch:
> $(MAKE) preflight
> if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then
>   echo "AUTO_UPDATE_FLAKE=1 -> updating flake"
>   $(MAKE) update-flake
> else
>   echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update"
> fi
> $(MAKE) check_git_status
> echo "Before:"
> $(MAKE) current-system
> $(call print_cmd,switch,)
> $(call nixos_cmd,switch,)
> echo "After:"
> $(MAKE) current-system
> $(MAKE) list-generations

build-debug:
> $(MAKE) preflight
> if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then $(MAKE) update-flake; else echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update"; fi
> $(MAKE) check_git_status
> $(call print_cmd,switch,--verbose --show-trace)
> $(call nixos_cmd,switch,--verbose --show-trace) | tee "$(DEBUG_LOG)"
> echo "Saved log: $(DEBUG_LOG)"

# ------------------------------------------
# Maintenance
# ------------------------------------------
fmt:
> $(call require_repo)
> cd "$(NIXOS_CONFIG)"
> nix fmt || nix run nixpkgs#nixpkgs-fmt -- .

rollback:
> sudo nixos-rebuild switch --rollback
> $(MAKE) list-generations

gc:
> sudo nix-collect-garbage

gc-hard:
> sudo nix-collect-garbage -d --delete-older-than 1d