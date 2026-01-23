# modules/features/devops.nix
# ---
{ config, lib, pkgs, devopsEnabled ? false, ... }:

let
  enable = devopsEnabled;
in
{
  config = lib.mkMerge [
    # Default OFF (serviços não sobem)
    {
      virtualisation.docker.enable = lib.mkDefault false;
      services.k3s.enable = lib.mkDefault false;
    }

    # DEVOPS=1 -> ON
    (lib.mkIf enable {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        daemon.settings.features.buildkit = true;
      };

      services.k3s = {
        enable = true;
        role = "server";
        extraFlags = [
          "--write-kubeconfig-mode=644"
          "--disable=traefik"
          "--disable=servicelb"
        ];
      };

      networking.firewall.allowedTCPPorts = [ 6443 ];

      # Tooling (opcional aqui; pode remover se já estiver em system-packages)
      environment.systemPackages = with pkgs; [
        docker
        docker-compose
        docker-buildx
        lazydocker
        k9s
        cri-tools
      ];

      users.users.borba.extraGroups = lib.mkAfter [ "docker" ];
    })
  ];
}
