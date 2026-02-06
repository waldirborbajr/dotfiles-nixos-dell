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
    # Deploy by copying: sudo cp keys/age.key /etc/nixos/keys/age.key
    sops.age.keyFile = "/etc/nixos/keys/age.key";
    sops.defaultSopsFile = ../../secrets.yaml;

    # Define secrets
    sops.secrets = {
      # Root secrets
      "github-token" = {
        mode = "0400";
      };

      # User secrets available at /run/secrets/borba/<secret name>
      "borba/github-token" = {
        owner = "borba";
        group = "borba";
        mode = "0400";
      };
      "borba/password-hash" = {
        neededForUsers = true;
      };
      "borba/email" = {
        owner = "borba";
        group = "borba";
        mode = "0400";
      };

      # Tailscale auth key - only on hosts with tailscale enabled
      "tailscale-auth-key" = lib.mkIf config.services.tailscale.enable {
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    # Generate git config with email from SOPS placeholder
    environment.etc."git-email-config".text = ''
      [user]
        email = ${config.sops.placeholder."borba/email"}
    '';
  };
}
