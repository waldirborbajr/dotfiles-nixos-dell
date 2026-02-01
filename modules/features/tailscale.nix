# modules/features/tailscale.nix
# Tailscale VPN mesh network
# https://tailscale.com/
{ config, lib, pkgs, ... }:

{
  options.features.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Tailscale VPN mesh network";
    };
  };

  config = lib.mkIf config.features.tailscale.enable {
    # Enable Tailscale service
    services.tailscale = {
      enable = true;
      # useRoutingFeatures = "both";  # Enable subnet routing and exit nodes
    };

    # Open firewall for Tailscale
    networking.firewall = {
      # Allow Tailscale traffic
      trustedInterfaces = [ "tailscale0" ];

      # Allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    # Tailscale CLI tool available system-wide
    environment.systemPackages = with pkgs; [
      tailscale
    ];
  };
}
