{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    hyprland
    waybar
    wofi
    mako
    grim
    slurp
    wl-clipboard
    swaylock
    swayidle
    networkmanagerapplet
    blueman
    alacritty
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
