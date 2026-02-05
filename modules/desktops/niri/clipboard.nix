# modules/desktops/niri/clipboard.nix
# Clipboard manager for Niri
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
lib.mkIf isMacbook {
  home.packages = with pkgs; [
    wl-clipboard     # Wayland clipboard utilities
    cliphist         # Clipboard history manager for Wayland
    wl-clip-persist  # Keep clipboard content after program closes
  ];

  # Cliphist configuration for clipboard history
  xdg.configFile."cliphist/config".text = ''
    max-items=1000
  '';

  # Optional: Add systemd service for cliphist
  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard history manager for Wayland";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
