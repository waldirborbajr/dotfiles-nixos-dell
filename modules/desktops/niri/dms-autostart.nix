# modules/desktops/niri/dms-autostart.nix
# Autostart script for DankMaterialShell with Niri
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  
  # DankMaterialShell start script
  dmsStart = pkgs.writeShellScriptBin "dms-start" ''
    #!/usr/bin/env bash
    # Start DankMaterialShell for Niri
    
    # Wait for Niri to be fully started
    sleep 2
    
    # Check if DankMaterialShell is available
    if command -v dank-material-shell &> /dev/null; then
      echo "Starting DankMaterialShell..."
      dank-material-shell &
    else
      echo "DankMaterialShell not found. Installing..."
      # TODO: Add installation method here
      # For now, log the message
      echo "Please install DankMaterialShell manually from:"
      echo "https://github.com/material-shell/material-shell"
    fi
  '';
in
lib.mkIf isMacbook {
  home.packages = [ dmsStart ];
  
  # Add autostart entry
  xdg.configFile."autostart/dank-material-shell.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=DankMaterialShell
    Comment=Modern Material Design shell for Wayland
    Exec=${dmsStart}/bin/dms-start
    Terminal=false
    StartupNotify=false
    X-GNOME-Autostart-enabled=true
    Categories=System;
  '';
}
