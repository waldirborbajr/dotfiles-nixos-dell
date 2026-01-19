{ pkgs, lib, ... }:

{
  ############################################
  # COSMIC Desktop (Wayland)
  ############################################

  services.xserver.enable = true;

  # GDM continua sendo o display manager
  services.xserver.displayManager.gdm.enable = true;

  ############################################
  # COSMIC
  ############################################
  services.desktopManager.cosmic.enable = true;

  ############################################
  # Wayland env
  ############################################
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  ############################################
  # Performance-friendly defaults
  ############################################

  # COSMIC já é mais leve que GNOME,
  # então evitamos efeitos extras
  services.desktopManager.cosmic.settings = {
    animations.enable = false;
    compositor.vsync = true;
  };
}
