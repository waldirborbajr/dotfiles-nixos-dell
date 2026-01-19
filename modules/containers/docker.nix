{ config, pkgs, ... }:

{
  ############################################
  # Docker (system service)
  ############################################
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  ############################################
  # User access
  ############################################
  users.users.borba.extraGroups = [ "docker" ];
}
