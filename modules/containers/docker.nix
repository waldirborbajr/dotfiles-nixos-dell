{ config, pkgs, lib, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    docker-buildx
    lazydocker
  ];

  users.users.borba.extraGroups = lib.mkAfter [ "docker" ];
}
