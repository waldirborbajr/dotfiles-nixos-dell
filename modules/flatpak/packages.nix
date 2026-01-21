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
    "org.flameshot.Flameshot"
    "com.ticktick.TickTick"
  ];
}
