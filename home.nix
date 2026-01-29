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

    # Apps (all available, enable below)
    ./modules/apps

    # Languages (all available, enable below)
    ./modules/languages
  ] ++ lib.optionals isMacbook [
    ./modules/desktops/niri
  ];

  # ==========================================
  # Enable apps via options
  # ==========================================
  apps = {
    # Core apps
    shell.enable = true;
    terminals.enable = true;
    fastfetch.enable = true;
    dev-tools.enable = true;
    ripgrep.enable = true;
    yazi.enable = true;
    tmux.enable = true;
    chirp.enable = false;
    
    # User apps (migrated from system)
    browsers.enable = true;
    communication.enable = true;
    editors.enable = true;
    ides.enable = true;
    knowledge.enable = true;
    media.enable = true;
    productivity.enable = true;
    remote.enable = false;      # Enable if needed
    clipboard.enable = true;
    multiplexers.enable = true;
  };

  # ==========================================
  # Enable languages via options
  # ==========================================
  languages = {
    # Home-manager level (per-project/optional)
    go.enable = false;
    rust.enable = false;
    lua.enable = false;
    nix-dev.enable = true;
    
    # System-level toolchains (home-manager configs)
    python.enable = true;
    nodejs.enable = true;
  };

  # ==========================================
  # Wayland/Desktop packages (conditional)
  # ==========================================
  home.packages = lib.optionals isMacbook (with pkgs; [
    waybar
    mako
    fuzzel
    wl-clipboard
    grim
    slurp
    swappy
    playerctl
  ]);

  # ==========================================
  # Session variables (non-redundant)
  # ==========================================
  home.sessionVariables = {
    # Terminal preference
    TERMINAL = "alacritty";
  };
}
