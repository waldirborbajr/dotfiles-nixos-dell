# modules/flatpak/packages.nix
{ ... }:

{
  services.flatpak.packages = [
    # Browsers
    "org.mozilla.firefox"
#    "org.mozilla.firefoxdeveloperedition"
#    "org.chromium.Chromium"
    "com.brave.Browser"
#    "com.vivaldi.Vivaldi"

    # Development / IDE
    "com.visualstudio.code"
#    "com.google.AndroidStudio"

    # Communication
    "com.discordapp.Discord"
    "me.proton.Mail"

    # Knowledge / Media
    "md.obsidian.Obsidian"
#    "com.obsproject.Studio"

    # Utilities
    "com.anydesk.Anydesk"
#    "com.ticktick.TickTick"

    # Media / Graphics
    "org.gimp.GIMP"
    "org.inkscape.Inkscape"
    "org.audacityteam.Audacity"
    "fr.handbrake.ghb"
    "io.mpv.Mpv"
    "org.imagemagick.ImageMagick"

    # Documents / Publishing
#    "com.calibre_ebook.calibre"
#    "org.libreoffice.LibreOffice"

    # Downloads / Torrents
    "com.transmissionbt.Transmission"    

    # Screen Shot
    "be.alexandervanhee.gradia"
    "org.flameshot.Flameshot"
  ];
}
