{ config, pkgs, ... }:

{
  ####################################################################
  # Podman (FUTURE USE)
  #
  # This configuration is intentionally DISABLED.
  #
  # Planned migration path:
  # 1. Disable Docker:
  #    virtualisation.docker.enable = false;
  #
  # 2. Enable Podman below and rebuild.
  #
  # Notes:
  # - dockerCompat MUST NOT be enabled together with Docker.
  # - This setup is rootless and Docker-CLI compatible.
  ####################################################################

  # virtualisation.podman = {
  #   enable = true;
  #
  #   # Docker-compatible CLI and socket
  #   dockerCompat = true;
  #
  #   # Default bridge with DNS enabled
  #   defaultNetwork.settings = {
  #     dns_enabled = true;
  #   };
  # };

  # Required for rootless Podman
  # users.users.borba.linger = true;

  # Firewall exception for Podman bridge
  # networking.firewall.trustedInterfaces = [
  #   "podman0"
  # ];
}
