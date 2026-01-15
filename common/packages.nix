{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
  # Core
    wget
    coreutils
    git
    gh
    lazygit
    stow
    tmux
    tmuxifier
    lshw
    iwd
    networkmanagerapplet

    # Containers
    docker
    docker-compose
    devpod

    # Wayland
    alacritty
    waybar
    rofi
    wl-clipboard

    # Modern CLI tools
    eza
    btop
    bat
    htop
    fd
    ripgrep
    yazi

    # Go
    go
    gopls

    # Rust
    rustup
    # cargo
    rust-analyzer

    # Nix
    nixd
    nil
    statix
    deadnix
    nixfmt-rfc-style

    # Editor
    neovim
  ];
}