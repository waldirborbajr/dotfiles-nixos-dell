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
    chirp.enable = true;

    # User apps (migrated from system)
    browsers.enable = true;
    communication.enable = true;
    helix.enable = false;
    neovim.enable = true;
    starship.enable = true;
    ides.enable = true;
    knowledge.enable = true;

    # Media tools - granular options available (Dendritic Pattern)
    # Use: apps.media.enable = true; for all, or enable individually:
    #   apps.media.image.enable = true;    # GIMP, Inkscape, ImageMagick
    #   apps.media.audio.enable = true;    # Audacity, MPV
    #   apps.media.video.enable = true;    # Handbrake
    #   apps.media.torrents.enable = true; # Transmission
    media.enable = true;

    # Productivity tools - granular options available (Dendritic Pattern)
    # Use: apps.productivity.enable = true; for all, or enable individually:
    #   apps.productivity.file-tools.enable = true;      # eza, fd, dust, ncdu, tree
    #   apps.productivity.navigation.enable = true;      # zoxide
    #   apps.productivity.shell-history.enable = true;   # atuin
    #   apps.productivity.text-processing.enable = true; # sd, jq, fx, tldr
    #   apps.productivity.http-clients.enable = true;    # httpie
    #   apps.productivity.workflow.enable = true;        # direnv, entr
    #   apps.productivity.monitoring.enable = true;      # procs, btop
    #   apps.productivity.git-ui.enable = true;          # lazygit
    productivity.enable = true;

    remote.enable = false; # Enable if needed
    clipboard.enable = true;
    zellij.enable = false; # Tmux alternative (disabled by default)
    latex.enable = false; # Enable for LaTeX documents

    # Virtualization tools
    virtualbox.enable = false;
    distrobox.enable = false;

    # Fun CLI tools
    cbonsai.enable = true;
    cmatrix.enable = false;
    pipes.enable = false;
    tty-clock.enable = false;
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
