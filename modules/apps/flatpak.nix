# modules/apps/flatpak.nix
# Consolidado: enable + packages
{ config, pkgs, lib, ... }:

let
  desired = [
    # Browsers
    "org.mozilla.firefox"
    "com.brave.Browser"

    # Development / IDE
    "com.visualstudio.code"

    # Communication
    "com.discordapp.Discord"
    "me.proton.Mail"

    # Knowledge / Media
    "md.obsidian.Obsidian"

    # Utilities
    "com.anydesk.Anydesk"

    # Media / Graphics
    "org.gimp.GIMP"
    "org.inkscape.Inkscape"
    "org.audacityteam.Audacity"
    "fr.handbrake.ghb"
    "io.mpv.Mpv"
    "org.imagemagick.ImageMagick"

    # Downloads / Torrents
    "com.transmissionbt.Transmission"

    # Screen Shot
    "be.alexandervanhee.gradia"
    "org.flameshot.Flameshot"
  ];
in
{
  services.flatpak.enable = true;

  environment.systemPackages = lib.optionals config.services.flatpak.enable [
    pkgs.flatpak
  ];

  # Garante o remote, mas não faz update/install/uninstall no rebuild
  system.userActivationScripts.flatpak-remote = ''
    if command -v flatpak >/dev/null 2>&1; then
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true
    fi
  '';

  # NOTE:
  # xdg.portal é gerenciado pelos módulos de desktop (Hyprland/GNOME) para evitar duplicação
}
