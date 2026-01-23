# modules/desktops/gnome.nix
# ---
{ pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  services.desktopManager.gnome.enable = true;

  # GNOME services (keep minimal & useful even outside GNOME)
  services.gnome = {
    core-apps.enable = true;
    gnome-keyring.enable = true;
  };

  # Session variables (avoid forcing session type globally)
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  # IMPORTANT:
  # Do not force xdg.portal here. Hyprland module should own the portal setup for Hyprland sessions.
  # GNOME works fine with its own integration when logging into GNOME via GDM.
}
