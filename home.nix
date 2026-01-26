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
    # Theme (home-manager level)
    ./modules/themes

    # Apps consolidados
    ./modules/apps/shell.nix       # zsh + fzf + bat
    ./modules/apps/terminals.nix   # alacritty terminal
    ./modules/apps/dev-tools.nix   # git + gh (core tools)
    ./modules/apps/ripgrep.nix     # ripgrep with DevOps config
    ./modules/apps/yazi.nix        # yazi file manager with DevOps optimizations
    ./modules/apps/tmux.nix        # tmux with Catppuccin theme

    # Languages (development environments)
    ./modules/languages/go.nix
    ./modules/languages/rust.nix
    ./modules/languages/lua.nix
    ./modules/languages/nix-dev.nix

    # Niri no macbook (está em desktops agora)
  ] ++ lib.optionals isMacbook [
    ./modules/desktops/niri.nix
  ];

  home.packages = with pkgs; [
    zoxide
    eza
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
    TERMINAL = "alacritty";
    NPM_CONFIG_UPDATE_NOTIFIER = "false";
    NPM_CONFIG_FUND = "false";
    NPM_CONFIG_AUDIT = "false";
    PYTHONDONTWRITEBYTECODE = "1";
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
  };
}
