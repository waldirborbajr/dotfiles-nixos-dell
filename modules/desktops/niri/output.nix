# modules/desktops/niri/output.nix
# Output/monitor configuration
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  outputConfig = ''
    // ============================================
    // OUTPUT CONFIGURATION
    // ============================================
    output "eDP-1" {
      mode "1920x1080@60.000"
      scale 1.0
      transform "normal"
      position x=0 y=0
    }
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/output.kdl".text = outputConfig;
}
