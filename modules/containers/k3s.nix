{ config, pkgs, ... }:

{
  ############################################
  # K3s (single-node workstation cluster)
  ############################################
  services.k3s = {
    enable = true;
    role = "server";

    extraFlags = [
      "--write-kubeconfig-mode=644"
      "--disable=traefik"
      "--disable=servicelb"
    ];
  };

  ############################################
  # Firewall
  ############################################
  networking.firewall.allowedTCPPorts = [
    6443 # Kubernetes API
  ];
}
