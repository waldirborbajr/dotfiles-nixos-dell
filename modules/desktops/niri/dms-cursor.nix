# modules/desktops/niri/dms-cursor.nix
# DMS cursor configuration include file
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  
  dmsCursorConfig = ''
    // ============================================
    // DMS CURSOR CONFIGURATION
    // ============================================
    // This file is included from the main config
    // Additional DMS-specific cursor settings can go here
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/dms/cursor.kdl".text = dmsCursorConfig;
}
