# modules/virtualization/default.nix
# ============================================
# Container Runtime Management
# ============================================
# 
# ATENÇÃO: Escolha APENAS UM container runtime por vez!
# Docker e Podman NÃO devem estar habilitados simultaneamente.
#
# Para trocar entre Docker e Podman:
#   1. Comente a importação atual (adicione #)
#   2. Descomente a importação desejada (remova #)
#   3. sudo nixos-rebuild switch --flake .#hostname
#
# ============================================

{ config, pkgs, lib, ... }:

{
  imports = [
    # ============================================
    # CONTAINER RUNTIME (escolha apenas 1)
    # ============================================

    # Docker (padrão atual - migração em andamento)
    ./docker.nix

    # Podman (próximo padrão - descomentar quando migração concluir)
    # ./podman.nix

    # ============================================
    # OUTROS SERVIÇOS (independentes)
    # ============================================

    # K3s - Kubernetes leve (se necessário)
    # ./k3s.nix

    # Libvirt - VMs com QEMU/KVM (se necessário)
    # ./libvirt.nix
  ];

  # ============================================
  # Verificação de segurança (assertions)
  # ============================================
  config = {
    assertions = [
      {
        assertion = !(config.virtualisation.docker.enable && config.virtualisation.podman.enable);
        message = ''
          ❌ ERRO: Docker e Podman não podem estar habilitados simultaneamente!
          
          Edite modules/virtualization/default.nix e:
            - Comente uma das importações (docker.nix ou podman.nix)
            - Mantenha apenas um container runtime ativo
        '';
      }
    ];
  };
}
