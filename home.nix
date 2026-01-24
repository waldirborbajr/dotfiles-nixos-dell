# home.nix
{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName or "unknown";
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";  # ajuste se necessário
in
{
  home.stateVersion = "25.11";
  home.username = "borba";
  home.homeDirectory = lib.mkForce "/home/borba";

  imports = [
    ./modules/apps/zsh.nix
    ./modules/apps/fzf.nix
    ./modules/apps/git.nix
    ./modules/apps/gh.nix
    ./modules/apps/go.nix
    ./modules/apps/rust.nix

    # Niri só no macbook — avalia o módulo corretamente
    (lib.mkIf isMacbook (import ./modules/apps/niri.nix { inherit config pkgs lib; }))
  ];

  # Pacotes comuns a todos
  home.packages = with pkgs; [
    git
    fzf
    zoxide
    eza
    bat
    ripgrep
    fd
    tree
  ] ++ lib.optional isMacbook (with pkgs; [
    # Pacotes específicos do Niri (só no macbook)
    waybar
    mako
    fuzzel
    alacritty
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
