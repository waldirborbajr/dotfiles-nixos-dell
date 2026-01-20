{ pkgs, lib, ... }:

{
  ############################################
  # X Server + GNOME
  ############################################
  services.xserver.enable = true;

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false;
  };

  services.desktopManager.gnome.enable = true;

  services.gnome = {
    core-apps.enable = true;   # Mantemos true para compatibilidade
    gnome-keyring.enable = true;
  };

  ############################################
  # Wayland Environment Variables
  ############################################
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "alacritty";
  };

  ############################################
  # XDG Portals
  ############################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  ############################################
  # Auto-login
  ############################################
  services.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  ############################################
  # Remove TTY concorrente
  ############################################
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ############################################
  # Journald logs limits
  ############################################
  services.journald.extraConfig = ''
    SystemMaxUse=200M
    RuntimeMaxUse=50M
  '';

  ############################################
  # Network
  ############################################
  systemd.services.NetworkManager-wait-online.enable = false;
}
