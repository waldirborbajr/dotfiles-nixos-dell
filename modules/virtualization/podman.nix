# modules/containers/podman.nix
# ---
{ config, pkgs, lib, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages =
    lib.optionals config.virtualisation.podman.enable (with pkgs; [
      podman
      podman-compose
      buildah
      skopeo
    ]);

  services.userManagement.enable = true;

  users.users.borba.linger = true;
}


# # modules/containers/podman.nix
# # ---
# { config, pkgs, lib, ... }:

# {
#   virtualisation.podman = {
#     enable = true;
#     dockerCompat = true;
#     defaultNetwork.settings.dns_enabled = true;
#   };

#   environment.systemPackages = with pkgs; [
#     podman
#     podman-compose
#     buildah
#     skopeo
#   ];

#   # Podman rootless correto
#   services.userManagement.enable = true;

#   users.users.borba = {
#     linger = true;
#   };
# }
