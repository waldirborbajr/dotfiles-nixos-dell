# modules/desktops/gnome.nix
# Optimized GNOME + Wayland configuration
{ pkgs, lib, ... }:

{
  # ============================================
  # Display Server & Session Manager
  # ============================================
  services.xserver.enable = true;

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false; # Prevent auto-suspend at login screen
  };

  services.desktopManager.gnome.enable = true;

  # ============================================
  # GNOME Services (minimal but complete)
  # ============================================
  services.gnome = {
    core-apps.enable = false; # Disabled: Calendar, Contacts, Clock, etc. (~500MB)
    gnome-keyring.enable = true;
    gnome-browser-connector.enable = true; # For GNOME Shell extensions
  };

  # ============================================
  # Performance Optimizations
  # ============================================
  # Disable unnecessary GNOME services
  services.gnome.games.enable = false;

  # Exclude bloat packages
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany # GNOME Web browser
    geary # Email client
    gnome-music
    gnome-photos
    totem # Video player
    cheese # Webcam app
    simple-scan
    yelp # Help viewer
    gnome-maps
    gnome-weather
    gnome-contacts
    gnome-calendar
  ];

  # ============================================
  # Wayland Environment Variables
  # ============================================
  environment.sessionVariables = {
    # Wayland support
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";

    # XDG
    XDG_SESSION_TYPE = "wayland";

    # GNOME-specific
    MUTTER_DEBUG_ENABLE_ATOMIC_KMS = "0"; # Better stability on some hardware
    MUTTER_DEBUG_FORCE_KMS_MODE = "simple";
  };

  # ============================================
  # GNOME Settings (dconf)
  # ============================================
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/wm/preferences" = {
        auto-maximize = false; # Prevent windows from auto-maximizing
      };

      # Wallpaper configuration
      "org/gnome/desktop/background" = {
        picture-uri = "file:///etc/nixos/wallpapers/devops-dark.svg";
        picture-uri-dark = "file:///etc/nixos/wallpapers/devops-dark.svg";
        picture-options = "zoom";
      };
    };
  }];

  # ============================================
  # XDG Portal Configuration
  # ============================================
  # GNOME provides its own portal implementation
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome  # GNOME portal for screenshots, etc.
      xdg-desktop-portal-gtk    # Fallback for non-GNOME apps
    ];
    config.common.default = "gnome";
  };

  # ============================================
  # Essential GNOME Packages
  # ============================================
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager
    dconf-editor

    # File manager integration
    nautilus
    sushi # File previewer for Nautilus

    # System utilities
    gnome-system-monitor

    # Terminal (if not using Alacritty/others)
    gnome-console
  ];

  # ============================================
  # Wallpaper
  # ============================================
  environment.etc."nixos/wallpapers/devops-dark.svg".source = ../../wallpapers/devops-dark.svg;
}
