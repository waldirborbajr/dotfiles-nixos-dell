# ==========================================
# NixOS Infra Makefile (Borba - NixGuru, stable)
# ==========================================

# Run every recipe as ONE bash script, strict mode.
SHELL := /usr/bin/env
.ONESHELL:
.SHELLFLAGS := bash -euo pipefail -c

# Silence command echo globally (avoid @-prefix problems forever)
.SILENT:

.DEFAULT_GOAL := help

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
AUTO_UPDATE_FLAKE ?= 0   # safer default
AUTO_GIT_COMMIT ?= 1     # keep behavior by default

.PHONY: \
	help hosts doctor flake-show \
	preflight flake-check eval-host \
	update-flake check_git_status \
	build switch switch-off upgrade rollback \
	dry-build dry-switch build-debug \
	list-generations current-system why-no-new-generation \
	fmt status gc gc-hard \
	flatpak-setup flatpak-update flatpak-update-repo

# ------------------------------------------
# Shared bash helpers
# ------------------------------------------
define BASH_LIB
die() { echo "ERROR: $$*" >&2; exit 1; }

need_cmd() { command -v "$$1" >/dev/null 2>&1 || die "Missing command: $$1"; }

need_repo() {
	[[ -e "$(NIXOS_CONFIG)/flake.nix" ]] || die "flake.nix not found in: $(NIXOS_CONFIG) (set NIXOS_CONFIG=/path/to/repo)";
}

need_flakes() {
	nix --extra-experimental-features "nix-command flakes" flake show "$(NIXOS_CONFIG)" >/dev/null 2>&1 \
		|| die "Flakes not working OR flake invalid. Try: nix --extra-experimental-features \"nix-command flakes\" flake show $(NIXOS_CONFIG)";
}

need_host() {
	[[ -n "$(HOST)" ]] || die "HOST is required. Example: make switch HOST=macbook (try: make hosts)";
}

need_flake_host() {
	nix --extra-experimental-features "nix-command flakes" eval --raw \
		"$(NIXOS_CONFIG)#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath" \
		>/dev/null 2>&1 || die "HOST='$(HOST)' not found in flake outputs (try: make hosts)";
}

maybe_sudo() {
	if ! sudo -n true >/dev/null 2>&1; then
		echo "INFO: sudo password may be required."
	fi
}

show_flags() {
	echo "Flags: HOST=$(HOST) IMPURE=$(IMPURE) DEVOPS=$(DEVOPS) QEMU=$(QEMU)"
}

maybe_update_flake() {
	if [[ "$(AUTO_UPDATE_FLAKE)" == "1" ]]; then
		echo "AUTO_UPDATE_FLAKE=1 -> updating flake.lock"
		$(MAKE) update-flake
	else
		echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update."
	fi
}

nixos_cmd() {
	local action="$$1"; shift || true
	local extra="$$*"

	local envprefix=""
	[[ -n "$(DEVOPS)" ]] && envprefix="$$envprefix DEVOPS=1"
	[[ -n "$(QEMU)"   ]] && envprefix="$$envprefix QEMU=1"

	local imp=""
	[[ -n "$(IMPURE)" ]] && imp="--impure"

	echo ">>> nixos-rebuild command:"
	echo "    $$envprefix sudo nixos-rebuild $$action --flake $(NIXOS_CONFIG)#$(HOST) $$imp $$extra"

	# shellcheck disable=SC2086
	$$envprefix sudo nixos-rebuild "$$action" \
		--flake "$(NIXOS_CONFIG)#$(HOST)" \
		$$imp $$extra
}
endef
export BASH_LIB

# ------------------------------------------
# Help
# ------------------------------------------
help:
	echo "NixOS Infrastructure Commands (flakes) — stable edition"
	echo ""
	echo "Start:"
	echo "  make hosts"
	echo "  make doctor"
	echo ""
	echo "Build/Switch:"
	echo "  make build  HOST=<host> [DEVOPS=1] [QEMU=1] [IMPURE=1]"
	echo "  make switch HOST=<host> [DEVOPS=1] [QEMU=1] [IMPURE=1]"
	echo "  make dry-switch HOST=<host>"
	echo ""
	echo "Upgrade (updates flake.lock):"
	echo "  make upgrade HOST=<host>"
	echo ""
	echo "Maintenance:"
	echo "  make fmt"
	echo "  make list-generations"
	echo "  make current-system"
	echo "  make rollback CONFIRM=YES"
	echo "  make gc-hard CONFIRM=YES"
	echo ""
	echo "Toggles:"
	echo "  AUTO_UPDATE_FLAKE=0 (default) -> safer"
	echo "  AUTO_GIT_COMMIT=1 (default) -> keeps your behavior"

# ------------------------------------------
# Discovery / Diagnostics
# ------------------------------------------
hosts:
	$(BASH_LIB)
	need_repo
	echo "Available hosts from flake outputs:"
	if command -v jq >/dev/null 2>&1; then
		cd "$(NIXOS_CONFIG)"
		nix --extra-experimental-features "nix-command flakes" flake show --json \
			| jq -r '.nixosConfigurations | keys[]'
	else
		echo "NOTE: jq not installed. Showing flake show summary:"
		cd "$(NIXOS_CONFIG)"
		nix --extra-experimental-features "nix-command flakes" flake show | sed -n '1,140p'
		echo "TIP: install jq for clean host listing."
	fi

flake-show:
	$(BASH_LIB)
	need_repo
	cd "$(NIXOS_CONFIG)"
	nix --extra-experimental-features "nix-command flakes" flake show

doctor:
	$(BASH_LIB)
	need_repo
	need_cmd nix
	need_flakes
	echo "OK: repo + nix + flakes look good."
	echo "Repo: $(NIXOS_CONFIG)"
	echo "Tip: make hosts"

# ------------------------------------------
# Preflight
# ------------------------------------------
preflight:
	$(BASH_LIB)
	need_repo
	need_cmd nix
	need_flakes
	maybe_sudo
	need_host
	need_flake_host
	show_flags

flake-check:
	$(BASH_LIB)
	need_repo
	echo "Running flake check..."
	cd "$(NIXOS_CONFIG)"
	nix --extra-experimental-features "nix-command flakes" flake check

eval-host:
	$(BASH_LIB)
	need_repo
	need_host
	need_flake_host
	echo "Evaluating toplevel drvPath for host $(HOST)..."
	cd "$(NIXOS_CONFIG)"
	nix --extra-experimental-features "nix-command flakes" eval --raw \
		".#nixosConfigurations.$(HOST).config.system.build.toplevel.drvPath"

# ------------------------------------------
# Update flake
# ------------------------------------------
update-flake:
	$(BASH_LIB)
	need_repo
	echo "Updating flake.lock in $(NIXOS_CONFIG)..."
	cd "$(NIXOS_CONFIG)"
	nix --extra-experimental-features "nix-command flakes" flake update

# ------------------------------------------
# Git auto-commit
# ------------------------------------------
check_git_status:
	$(BASH_LIB)
	need_repo
	echo "Checking Git status in $(NIXOS_CONFIG)..."
	if [[ "$(AUTO_GIT_COMMIT)" != "1" ]]; then
		echo "AUTO_GIT_COMMIT=0 -> skipping auto-commit."
		exit 0
	fi
	if [[ -n "$$(git -C "$(NIXOS_CONFIG)" status --porcelain)" ]]; then
		echo "Git changes detected -> auto add/commit..."
		git -C "$(NIXOS_CONFIG)" add .
		git -C "$(NIXOS_CONFIG)" commit -m "$(GIT_COMMIT_MSG)" || true
		if [[ "$(GIT_PUSH)" == "1" ]]; then
			git -C "$(NIXOS_CONFIG)" push
		fi
	else
		echo "No git changes detected."
	fi

# ------------------------------------------
# Generations / pointers
# ------------------------------------------
list-generations:
	echo ""
	sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 30

current-system:
	echo "Current system -> $$(readlink -f /run/current-system)"
	echo "System profile -> $$(readlink -f /nix/var/nix/profiles/system)"

why-no-new-generation:
	echo "If generations don't advance, one of these is true:"
	echo "  1) output identical (toplevel didn't change)"
	echo "  2) module not imported for this host"
	echo "  3) rebuild failed before activation"
	echo ""
	$(MAKE) current-system
	echo ""
	$(MAKE) list-generations

# ------------------------------------------
# Format
# ------------------------------------------
fmt:
	$(BASH_LIB)
	need_repo
	echo "Formatting Nix files..."
	cd "$(NIXOS_CONFIG)"
	(nix fmt || nix run nixpkgs#nixpkgs-fmt -- .)
	git -C "$(NIXOS_CONFIG)" status

# ------------------------------------------
# Build / Switch
# ------------------------------------------
dry-switch:
	$(MAKE) preflight
	$(BASH_LIB)
	nixos_cmd switch --dry-run

dry-build:
	$(MAKE) preflight
	$(BASH_LIB)
	nixos_cmd build --dry-run

build:
	$(MAKE) preflight
	$(BASH_LIB)
	maybe_update_flake
	$(MAKE) check_git_status
	$(MAKE) flake-check
	echo "Before:"
	$(MAKE) current-system
	nixos_cmd build
	echo "After:"
	$(MAKE) current-system
	$(MAKE) list-generations

switch:
	$(MAKE) preflight
	$(BASH_LIB)
	maybe_update_flake
	$(MAKE) check_git_status
	$(MAKE) flake-check
	echo "Before:"
	$(MAKE) current-system
	nixos_cmd switch
	echo "After:"
	$(MAKE) current-system
	$(MAKE) list-generations

switch-off:
	$(MAKE) preflight
	$(BASH_LIB)
	sudo systemctl isolate multi-user.target
	nixos_cmd switch
	sudo systemctl isolate graphical.target

upgrade:
	$(MAKE) preflight
	$(BASH_LIB)
	$(MAKE) update-flake
	$(MAKE) check_git_status
	$(MAKE) flake-check
	nixos_cmd switch
	$(MAKE) list-generations

build-debug:
	$(MAKE) preflight
	$(BASH_LIB)
	maybe_update_flake
	$(MAKE) check_git_status
	echo ">>> running verbose build (log -> $(DEBUG_LOG))"
	# shellcheck disable=SC2046
	( set -x; nixos_cmd switch --verbose --show-trace ) | tee "$(DEBUG_LOG)"
	echo "Saved log: $(DEBUG_LOG)"

rollback:
	$(BASH_LIB)
	if [[ "$(CONFIRM)" != "YES" ]]; then
		die "Refusing to rollback without confirmation. Run: make rollback CONFIRM=YES"
	fi
	sudo nixos-rebuild switch --rollback
	$(MAKE) list-generations

# ------------------------------------------
# Maintenance
# ------------------------------------------
gc:
	sudo nix-collect-garbage

gc-hard:
	$(BASH_LIB)
	if [[ "$(CONFIRM)" != "YES" ]]; then
		die "Refusing destructive GC without confirmation. Run: make gc-hard CONFIRM=YES"
	fi
	sudo nix-collect-garbage -d --delete-older-than 1d

status:
	systemctl --user list-jobs

# ------------------------------------------
# Flatpak
# ------------------------------------------
flatpak-setup:
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak-update:
	flatpak update -y

flatpak-update-repo:
	flatpak update --appstream -y && flatpak update -y