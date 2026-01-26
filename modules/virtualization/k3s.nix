# modules/virtualization/k3s.nix
# K3s - Lightweight Kubernetes cluster
# Pode ser desabilitado via: services.k3s.enable = false;

{ config, pkgs, lib, ... }:

{
  services.k3s = {
    enable = lib.mkDefault false;  # Disabled by default
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode=644"
      "--disable=traefik"
      "--disable=servicelb"
    ];
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.k3s.enable [
    6443  # Kubernetes API
  ];

  environment.systemPackages = lib.mkIf config.services.k3s.enable [
    pkgs.k9s
    pkgs.kubectl
    pkgs.kubernetes-helm
  ];
}
