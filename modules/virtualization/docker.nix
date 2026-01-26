# modules/containers/docker.nix
{ config, pkgs, lib, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings.features.buildkit = true;
  };

  environment.systemPackages =
    lib.optionals config.virtualisation.docker.enable [
      pkgs.docker
      pkgs.docker-compose
      pkgs.docker-buildx
      pkgs.lazydocker
    ];

  users.users.borba.extraGroups = lib.mkAfter [ "docker" ];
}


# # modules/containers/docker.nix
# # ---
# { config, pkgs, lib, ... }:

# {
#   virtualisation.docker = {
#     enable = true;
#     enableOnBoot = true;
#     daemon.settings = {
#       features = {
#         buildkit = true;
#       };
#     };
#   };

#   environment.systemPackages = with pkgs; [
#     docker
#     docker-compose
#     docker-buildx
#     lazydocker
#   ];

#   users.users.borba.extraGroups = lib.mkAfter [ "docker" ];
# }

