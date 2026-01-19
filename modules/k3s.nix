{ config, pkgs, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode=644"
      "--disable=traefik"
      "--disable=servicelb"
    ];
  };
}
