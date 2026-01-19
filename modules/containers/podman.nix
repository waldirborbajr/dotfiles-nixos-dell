{ config, pkgs, ... }:

{
  ############################################
  # Podman (rootless, Docker-compatible)
  ############################################
  virtualisation.podman = {
    enable = true;

    # Enable Docker-compatible CLI and socket
    # Allows using Docker tools against Podman
    dockerCompat = true;

    # Enable default Podman bridge with DNS
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  ############################################
  # Rootless Podman requirements
  ############################################

  # Allow user services to run without active login
  users.users.borba.linger = true;

  ############################################
  # Firewall (Podman default bridge)
  ############################################
  networking.firewall.trustedInterfaces = [
    "podman0"
  ];
}
