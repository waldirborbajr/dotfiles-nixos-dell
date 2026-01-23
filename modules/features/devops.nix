{ config, lib, pkgs, devopsEnabled ? false, ... }:

let
  enable = devopsEnabled;
in
{
  # A ideia: instalar ferramentas pode ser sempre,
  # mas serviços só sobem quando DEVOPS=1.
  config = lib.mkMerge [
    {
      # Deixa explícito: serviços desativados por padrão
      virtualisation.docker.enable = lib.mkDefault false;
      services.k3s.enable = lib.mkDefault false;
    }

    (lib.mkIf enable {
      # DevOps mode ON
      virtualisation.docker.enable = true;
      services.k3s.enable = true;

      # (opcional) garante que sobem no boot quando em modo DevOps
      virtualisation.docker.enableOnBoot = true;

      # Ajuste comum: docker precisa do group
      users.users.borba.extraGroups = [ "docker" ];
    })
  ];
}
