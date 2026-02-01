# modules/desktops/niri/dms-scripts.nix
# Helper scripts for controlling DankMaterialShell
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  # Toggle DMS launcher
  dmsToggleLauncher = pkgs.writeShellScriptBin "dms-toggle-launcher" ''
    #!/usr/bin/env bash
    # Toggle DankMaterialShell app launcher
    if pgrep -x "dank-material" > /dev/null; then
      dbus-send --session --dest=org.dank.MaterialShell \
        --type=method_call \
        /org/dank/MaterialShell \
        org.dank.MaterialShell.ToggleLauncher
    else
      notify-send "DMS" "DankMaterialShell is not running"
    fi
  '';

  # Toggle notifications
  dmsToggleNotifications = pkgs.writeShellScriptBin "dms-toggle-notifications" ''
    #!/usr/bin/env bash
    # Toggle DankMaterialShell notification center
    if pgrep -x "dank-material" > /dev/null; then
      dbus-send --session --dest=org.dank.MaterialShell \
        --type=method_call \
        /org/dank/MaterialShell \
        org.dank.MaterialShell.ToggleNotifications
    else
      notify-send "DMS" "DankMaterialShell is not running"
    fi
  '';

  # Toggle control center
  dmsToggleControlCenter = pkgs.writeShellScriptBin "dms-toggle-control-center" ''
    #!/usr/bin/env bash
    # Toggle DankMaterialShell control center
    if pgrep -x "dank-material" > /dev/null; then
      dbus-send --session --dest=org.dank.MaterialShell \
        --type=method_call \
        /org/dank/MaterialShell \
        org.dank.MaterialShell.ToggleControlCenter
    else
      notify-send "DMS" "DankMaterialShell is not running"
    fi
  '';

  # Toggle clipboard history
  dmsToggleClipboard = pkgs.writeShellScriptBin "dms-toggle-clipboard" ''
    #!/usr/bin/env bash
    # Toggle DankMaterialShell clipboard history
    if pgrep -x "dank-material" > /dev/null; then
      dbus-send --session --dest=org.dank.MaterialShell \
        --type=method_call \
        /org/dank/MaterialShell \
        org.dank.MaterialShell.ToggleClipboard
    else
      # Fallback to cliphist if DMS is not running
      cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
    fi
  '';

  # Restart DMS
  dmsRestart = pkgs.writeShellScriptBin "dms-restart" ''
    #!/usr/bin/env bash
    # Restart DankMaterialShell
    echo "Restarting DankMaterialShell..."
    pkill -x dank-material-shell
    sleep 1
    if command -v dank-material-shell &> /dev/null; then
      dank-material-shell &
      notify-send "DMS" "DankMaterialShell restarted"
    else
      notify-send "DMS Error" "DankMaterialShell binary not found"
    fi
  '';

  # Show DMS status
  dmsStatus = pkgs.writeShellScriptBin "dms-status" ''
    #!/usr/bin/env bash
    # Show DankMaterialShell status
    if pgrep -x "dank-material" > /dev/null; then
      pid=$(pgrep -x "dank-material" | head -1)
      mem=$(ps -p $pid -o rss= | awk '{printf "%.1f MB", $1/1024}')
      cpu=$(ps -p $pid -o %cpu= | awk '{print $1"%"}')
      echo "✓ DankMaterialShell is running"
      echo "  PID: $pid"
      echo "  Memory: $mem"
      echo "  CPU: $cpu"
      notify-send "DMS Status" "Running\nPID: $pid\nMem: $mem\nCPU: $cpu"
    else
      echo "✗ DankMaterialShell is not running"
      notify-send "DMS Status" "Not running"
    fi
  '';

  # Apply DMS theme
  dmsApplyTheme = pkgs.writeShellScriptBin "dms-apply-theme" ''
    #!/usr/bin/env bash
    # Apply or change DankMaterialShell theme
    
    THEMES=(
      "catppuccin-mocha"
      "catppuccin-macchiato"
      "catppuccin-frappe"
      "catppuccin-latte"
      "nord"
      "dracula"
      "gruvbox"
    )
    
    # Show theme selection
    selected=$(printf '%s\n' "''${THEMES[@]}" | fuzzel --dmenu --prompt="Select DMS Theme: ")
    
    if [ -n "$selected" ]; then
      # Update config
      config_file="$HOME/.config/DankMaterialShell/config.json"
      if [ -f "$config_file" ]; then
        # Backup current config
        cp "$config_file" "$config_file.backup"
        
        # Update theme in config using jq
        jq ".currentThemeName = \"$selected\"" "$config_file" > "$config_file.tmp"
        mv "$config_file.tmp" "$config_file"
        
        # Restart DMS to apply theme
        dms-restart
        
        notify-send "DMS Theme" "Applied: $selected"
      else
        notify-send "DMS Error" "Config file not found"
      fi
    fi
  '';
in
lib.mkIf isMacbook {
  home.packages = [
    dmsToggleLauncher
    dmsToggleNotifications
    dmsToggleControlCenter
    dmsToggleClipboard
    dmsRestart
    dmsStatus
    dmsApplyTheme
    pkgs.jq # For config manipulation
  ];
}
