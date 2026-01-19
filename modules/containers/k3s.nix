{ config, pkgs, ... }:

{
  ############################################
  # K3s (single-node workstation cluster)
  ############################################
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = "--disable traefik";
  };

  ############################################
  # Firewall
  ############################################
  networking.firewall.allowedTCPPorts = [
    6443 # Kubernetes API
  ];
}
