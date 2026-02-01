# modules/virtualization/docker.nix
# Docker container runtime
# Pode ser desabilitado via: virtualisation.docker.enable = false;

{ config, pkgs, lib, ... }:

{
  virtualisation.docker = {
    enable = lib.mkDefault true;
    enableOnBoot = lib.mkDefault false; # Start on-demand to save RAM (~300MB)
    daemon.settings.features.buildkit = true;
  };

  environment.systemPackages = lib.mkIf config.virtualisation.docker.enable [
    pkgs.docker
    pkgs.docker-compose
    pkgs.docker-buildx
    pkgs.lazydocker
    pkgs.ctop
    pkgs.dive
    pkgs.trivy
  ];

  users.users.borba.extraGroups = lib.mkIf config.virtualisation.docker.enable [
    "docker"
  ];
}

