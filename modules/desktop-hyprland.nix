{ config, pkgs, lib, ... }:

{
  ############################################
  # Hyprland (Wayland compositor)
  ############################################

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  ############################################
  # Display manager (GDM Wayland-friendly)
  ############################################
  services.xserver = {
    enable = true;

    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  ############################################
  # Wayland environment
  ############################################
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";

    GTK_USE_PORTAL = "1";
  };

  ############################################
  # Portals (clipboard, screenshots, screenshare)
  ############################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  ############################################
  # Hyprland ecosystem tools (system-wide)
  ############################################
  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
    dunst
    wl-clipboard
    grim
    slurp
    swaybg
    hyprpaper
    hypridle
    hyprlock
  ];

  ############################################
  # Disable heavy effects globally
  ############################################
  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
