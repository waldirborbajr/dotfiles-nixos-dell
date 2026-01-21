{ config, pkgs, lib, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman
    podman-compose
    buildah
    skopeo
  ];

  # Podman rootless correto
  services.userManagement.enable = true;

  users.users.borba = {
    linger = true;
  };
}
