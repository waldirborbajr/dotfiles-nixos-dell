# modules/virtualization/podman.nix
# Podman container runtime (Docker alternative)
# Pode ser desabilitado via: virtualisation.podman.enable = false;

{ config, pkgs, lib, ... }:

{
  virtualisation.podman = {
    enable = lib.mkDefault true;
    dockerCompat = true;  # Alias 'docker' command to podman
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = lib.mkIf config.virtualisation.podman.enable [
    pkgs.podman
    pkgs.podman-compose
    pkgs.buildah
    pkgs.skopeo
  ];

  # Podman rootless support
  users.users.borba = lib.mkIf config.virtualisation.podman.enable {
    linger = true;
  };
}
