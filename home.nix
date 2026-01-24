# home.nix
{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName or "unknown";
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";  # ajuste se o hostname for diferente
in
{
  home.stateVersion = "25.11";
  home.username = "borba";
  home.homeDirectory = lib.mkForce "/home/borba";

  # Importa os módulos comuns a todos os hosts
  imports = [
    ./modules/apps/zsh.nix
    ./modules/apps/fzf.nix
    ./modules/apps/git.nix
    ./modules/apps/gh.nix
    ./modules/apps/go.nix
    ./modules/apps/rust.nix
    # Outros módulos comuns aqui (ex: starship, direnv, neovim, etc.)

    # Importa Niri SOMENTE no macbook
    (lib.mkIf isMacbook (import ./modules/apps/niri.nix))
  ];

  # Pacotes leves que podem ficar em todos (ou condicional se quiser)
  home.packages = with pkgs; [
    # Exemplos leves que rodam bem no dell
    git
    fzf
    zoxide
    eza
    bat
    ripgrep
    fd
    tree
  ] ++ (lib.mkIf isMacbook (with pkgs; [
    # Pacotes pesados só no macbook
    waybar
    mako
    fuzzel
    alacritty
    wl-clipboard
    grim
    slurp
    swappy
    playerctl
  ]));

  # Variáveis comuns
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
