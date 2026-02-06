# modules/virtualization/default.nix
# ============================================
# Container Runtime Management
# ============================================
# 
# WARNING: Choose ONLY ONE container runtime at a time!
# Docker and Podman must NOT be enabled simultaneously.
#
# To switch between Docker and Podman:
#   1. Comment the current import (add #)
#   2. Uncomment the desired import (remove #)
#   3. sudo nixos-rebuild switch --flake .#hostname
#
# ============================================

{ config, pkgs, lib, ... }:

{
  imports = [
    # ============================================
    # CONTAINER RUNTIME (choose only 1)
    # ============================================

    # Docker (current default - migration in progress)
    ./docker.nix

    # Podman (next default - uncomment when migration completes)
    # ./podman.nix

    # ============================================
    # OTHER SERVICES (independent)
    # ============================================

    # K3s - Lightweight Kubernetes (if needed)
    # ./k3s.nix

    # Libvirt - VMs with QEMU/KVM (if needed)
    # ./libvirt.nix
  ];

  # ============================================
  # Safety checks (assertions)
  # ============================================
  config = {
    assertions = [
      {
        assertion = !(config.virtualisation.docker.enable && config.virtualisation.podman.enable);
        message = ''
          ❌ ERROR: Docker and Podman cannot be enabled simultaneously!
          
          Edit modules/virtualization/default.nix and:
            - Comment one of the imports (docker.nix or podman.nix)
            - Keep only one container runtime active
        '';
      }
    ];
  };
}
