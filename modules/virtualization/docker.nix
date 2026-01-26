# modules/virtualization/docker.nix
# Docker container runtime
# Pode ser desabilitado via: virtualisation.docker.enable = false;

{ config, pkgs, lib, ... }:

{
  virtualisation.docker = {
    enable = lib.mkDefault true;
    enableOnBoot = lib.mkDefault true;
    daemon.settings.features.buildkit = true;
  };

  environment.systemPackages = lib.mkIf config.virtualisation.docker.enable [
    pkgs.docker
    pkgs.docker-compose
    pkgs.docker-buildx
    pkgs.lazydocker
  ];

  users.users.borba.extraGroups = lib.mkIf config.virtualisation.docker.enable [
    "docker"
  ];
}

