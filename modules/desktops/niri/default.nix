# modules/desktops/niri/default.nix
# Main Niri configuration module - Imports all sub-modules
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
{
  imports = [
    ./config.nix
    ./input.nix
    ./output.nix
    ./layout.nix
    ./keybindings.nix
    ./window-rules.nix
    ./animations.nix
    # New modular configurations
    ./audio.nix
    ./clipboard.nix
    ./noctalia.nix
    ./notifications.nix
    ./polkit.nix
    ./screenshot.nix
    # DankMaterialShell - Disabled (not available in nixpkgs)
    # ./dank-material-shell.nix
    # ./dms-autostart.nix
    # ./dms-scripts.nix
    # ./dms-cursor.nix
    ./waybar.nix
    ./mako.nix
    ./fuzzel.nix
  ];

  config = lib.mkIf isMacbook {
    # Core packages (specific packages moved to their respective modules)
    home.packages = with pkgs; [
      niri
      brightnessctl
      networkmanagerapplet
      blueman  # Bluetooth manager with system tray applet
      swaybg
      waypaper
      swayidle
    ];

    # Wallpaper
    home.file.".config/niri/wallpaper.svg".source = ../../../wallpapers/devops-dark.svg;

    # Waypaper configuration
    xdg.configFile."waypaper/config.ini".text = ''
      [Settings]
      language = en
      folder = ${config.home.homeDirectory}/.config/niri
      backend = swaybg
      monitors = All
      fill = fill
      sort = name
      color = #1e1e2e
      subfolders = False
      wallpaper = ${config.home.homeDirectory}/.config/niri/wallpaper.svg
    '';

    # Wayland environment variables
    home.sessionVariables = {
      # Wayland support
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      # XDG
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "niri";

      # Qt theming
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
  };
}
