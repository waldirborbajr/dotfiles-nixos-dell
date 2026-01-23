{ config, pkgs, lib, ... }:

{
  # Hyprland (Wayland compositor)
  programs.hyprland.enable = true;

  # Packages used by hyprland.conf + waybar
  environment.systemPackages = with pkgs; [
    hyprland
    waybar
    wofi
    mako
    grim
    slurp
    wl-clipboard
    swaylock
    swayidle

    # Tray applets
    networkmanagerapplet
    blueman

    # Terminal requested
    alacritty
  ];

  # Portals: crucial for Flatpak apps and screen-sharing on Wayland
/*
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
*/

xdg.portal = {
  enable = true;
  extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
};

  # Put the canonical configs in /etc/xdg (Nix-managed, immutable)
  environment.etc."xdg/hypr/hyprland.conf".source = ./hyprland.conf;
  environment.etc."xdg/waybar/config".source = ./waybar-config.json;
  environment.etc."xdg/waybar/style.css".source = ./waybar-style.css;

  # Create symlinks into ~/.config (no Home-Manager)
  # This makes it 100% consistent with the paths you asked for.
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

      ln -sf /etc/xdg/hypr/hyprland.conf "$HOME/.config/hypr/hyprland.conf"
      ln -sf /etc/xdg/waybar/config "$HOME/.config/waybar/config"
      ln -sf /etc/xdg/waybar/style.css "$HOME/.config/waybar/style.css"
    '';
  };
}
