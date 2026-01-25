# modules/desktops/hyprland/default.nix
# ---
# Unified Hyprland module (Wayland compositor) + Waybar + XDG portal + Nix-managed configs
# - No Home-Manager
# - Canonical configs live in /etc/xdg (immutable, Nix-managed)
# - Symlinks created into ~/.config for the user paths you want
# - Avoids global side-effects (does NOT force XDG_SESSION_TYPE)
{ config, pkgs, lib, ... }:

{
  ############################################
  # Hyprland
  ############################################
  programs.hyprland.enable = true;

  ############################################
  # Packages used by hyprland.conf + waybar
  ############################################
  environment.systemPackages = with pkgs; [
    # Hyprland + UI
    hyprland
    waybar
    wofi
    mako

    # Screenshots / selection
    grim
    slurp

    # Clipboard
    wl-clipboard

    # Lock/idle
    swaylock
    swayidle

    # Tray applets
    networkmanagerapplet
    blueman

  ];

  ############################################
  # Portals (crucial for Flatpak apps, file picker, screenshots, screen-share)
  ############################################
#  xdg.portal = {
#    enable = true;
#    extraPortals = with pkgs; [
#      xdg-desktop-portal-hyprland
#      xdg-desktop-portal-gtk
#    ];
#  };

  ############################################
  # Session variables (safe globally; do NOT force session type)
  ############################################
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
  };

  ############################################
  # Canonical configs in /etc/xdg (Nix-managed)
  ############################################
  environment.etc."xdg/hypr/hyprland.conf".source = ./hyprland.conf;
  environment.etc."xdg/waybar/config".source = ./waybar-config.json;
  environment.etc."xdg/waybar/style.css".source = ./waybar-style.css;

  ############################################
  # Symlinks into ~/.config (no Home-Manager)
  # - Creates links only if files do not exist, so you can override locally when needed
  ############################################
  systemd.user.services."xdg-config-links" = {
    description = "Symlink XDG configs from /etc/xdg to ~/.config";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      mkdir -p "$HOME/.config/hypr" "$HOME/.config/waybar"

      # Hyprland
      [ -e "$HOME/.config/hypr/hyprland.conf" ] || ln -s /etc/xdg/hypr/hyprland.conf "$HOME/.config/hypr/hyprland.conf"

      # Waybar
      [ -e "$HOME/.config/waybar/config" ] || ln -s /etc/xdg/waybar/config "$HOME/.config/waybar/config"
      [ -e "$HOME/.config/waybar/style.css" ] || ln -s /etc/xdg/waybar/style.css "$HOME/.config/waybar/style.css"
    '';
  };
}
