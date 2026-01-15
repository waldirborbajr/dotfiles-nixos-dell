{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.terminess-ttf
      nerd-fonts.blex-mono
      ibm-plex
      openmoji-color
    ];

    fontConfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "IBM Plex Sans" ];
      serif     = [ "IBM Plex Serif" ];
      emoji     = [ "OpenMoji Color" ];
    };

    enableDefaultPackages = true;  # ← era enableDefaultFonts
  };
}