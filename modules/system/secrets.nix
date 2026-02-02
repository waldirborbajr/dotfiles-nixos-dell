# modules/system/secrets.nix
# SOPS secrets management
# See SECRETS-MANAGEMENT.md for complete documentation
{ config, lib, ... }:

{
  options.system-config.secrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sops-nix secrets management";
    };
  };

  config = lib.mkIf config.system-config.secrets.enable {
    # Configure sops
    sops = {
      # Default secrets file (can be overridden per-host)
      defaultSopsFile = ../../secrets/common/secrets.yaml;
      
      # Age key location for decryption
      age.keyFile = "/home/borba/.config/sops/age/keys.txt";
      
      # Define secrets here
      # Example structure:
      # secrets = {
      #   ssh_private_key = {
      #     owner = "borba";
      #     path = "/home/borba/.ssh/id_ed25519";
      #     mode = "0600";
      #   };
      #   
      #   github_token = {
      #     owner = "borba";
      #     mode = "0600";
      #   };
      # };
    };
    
    # Ensure required directories exist
    system.activationScripts.setupSecretsDirectories = ''
      # SSH directory
      mkdir -p /home/borba/.ssh
      chown borba:users /home/borba/.ssh
      chmod 700 /home/borba/.ssh
      
      # SOPS age directory
      mkdir -p /home/borba/.config/sops/age
      chown -R borba:users /home/borba/.config/sops
    '';
  };
}
