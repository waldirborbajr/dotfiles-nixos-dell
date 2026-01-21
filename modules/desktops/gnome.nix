{ pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  services.desktopManager.gnome.enable = true;

  # Disable unnecessary GNOME services and animations
  services.gnome = {
    core-apps.enable = true;
    gnome-keyring.enable = true;
  };

  environment.sessionVariables = {
    # Wayland native
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";

    # Reduce frame scheduling overhead
    # MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
  };

  # Portals (required for Wayland apps)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };
}
