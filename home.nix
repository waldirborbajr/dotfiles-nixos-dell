# home.nix
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = (hostname == "macbook-nixos") || (hostname == "macbook");
in
{
  home.stateVersion = "25.11";
  home.username = "borba";
  home.homeDirectory = lib.mkForce "/home/borba";

  imports = [
    # Apps consolidados
    ./modules/apps/shell.nix       # zsh + fzf + bat
    ./modules/apps/terminals.nix   # alacritty + kitty
    ./modules/apps/dev-tools.nix   # git + gh + go + rust

    # Niri no macbook (está em desktops agora)
  ] ++ lib.optionals isMacbook [
    ./modules/desktops/niri.nix
  ];

  home.packages = with pkgs; [
    zoxide
    eza
    ripgrep
    fd
    tree
  ] ++ lib.optionals isMacbook (with pkgs; [
    waybar
    mako
    fuzzel
    wl-clipboard
    grim
    slurp
    swappy
    playerctl
  ]);

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    BROWSER = "com.brave.Browser";
    TERMINAL = "kitty";
    NPM_CONFIG_UPDATE_NOTIFIER = "false";
    NPM_CONFIG_FUND = "false";
    NPM_CONFIG_AUDIT = "false";
    PYTHONDONTWRITEBYTECODE = "1";
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
  };
}
