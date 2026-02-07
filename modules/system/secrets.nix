# modules/system/secrets.nix
# SOPS secrets management
# See SECRETS-MANAGEMENT.md for complete documentation
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.system-config.secrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sops-nix secrets management";
    };
  };

  config = lib.mkIf config.system-config.secrets.enable {
    environment.systemPackages = [ pkgs.sops ];

    # SOPS age key configuration
    # Use SSH host keys for system-level secrets (automatically available)
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    sops.defaultSopsFile = ../../secrets/common/secrets.yaml;

    # Define secrets
    sops.secrets = {
      # SSH keys (common across hosts)
      "ssh_private_key" = {
        owner = "borba";
        group = "borba";
        mode = "0400";
      };
      "ssh_public_key" = {
        owner = "borba";
        group = "borba";
        mode = "0444";
      };

      # Optional: Uncomment and add to secrets.yaml as needed
      # "github-token" = {
      #   mode = "0400";
      # };
      # "borba/github-token" = {
      #   owner = "borba";
      #   group = "borba";
      #   mode = "0400";
      # };
      # "borba/password-hash" = {
      #   neededForUsers = true;
      # };
      # "borba/email" = {
      #   owner = "borba";
      #   group = "borba";
      #   mode = "0400";
      # };
      # "tailscale-auth-key" = lib.mkIf config.services.tailscale.enable {
      #   owner = "root";
      #   group = "root";
      #   mode = "0400";
      # };
    };
  };
}
