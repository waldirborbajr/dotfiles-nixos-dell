# modules/features/devops.nix
# DevOps tooling (kubectl, helm, terraform, etc.)
# Container runtime (Docker/Podman) is managed in modules/virtualization/

{ config, lib, pkgs, devopsEnabled ? false, ... }:

let
  enable = devopsEnabled;
in
{
  config = lib.mkIf enable {
    # DevOps CLI tools
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
      terraform
      ansible
      k9s
      kubectx
      kubecolor
      stern
    ];
  };
}
