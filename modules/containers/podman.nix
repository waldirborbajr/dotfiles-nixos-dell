{ config, pkgs, ... }:

{
  ############################################
  # Podman (rootless, Docker-compatible)
  ############################################
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  ############################################
  # Enable cgroups v2 (required for podman)
  ############################################
  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=1" ];
}
