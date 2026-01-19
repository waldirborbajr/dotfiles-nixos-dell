{ pkgs, ... }:

{
  ############################################
  # System Packages (global)
  ############################################
  environment.systemPackages = with pkgs; [

    # -------------------------
    # Terminals
    # -------------------------
    alacritty
    kitty

    # -------------------------
    # Shell / Multiplexer
    # -------------------------
    zsh
    fish
    tmux
    tmuxifier
    stow

    # -------------------------
    # Editors / Git
    # -------------------------
    neovim
    lazygit
    git
    gh

    # -------------------------
    # Containers
    # -------------------------
    docker
    docker-compose
    lazydocker

    # -------------------------
    # Languages / Toolchains
    # -------------------------
    gcc
    libgcc
    glibc
    libcxx

    go
    gopls

    rustup
    rust-analyzer

    # -------------------------
    # Build / Dev tools
    # -------------------------
    cmake
    gnumake
    libtool
    libvterm
    gdb

    clang
    llvm
    lld

    # -------------------------
    # Nix tooling
    # -------------------------
    nixd
    nil
    statix
    deadnix
    nixfmt-rfc-style

    # -------------------------
    # Modern CLI
    # -------------------------
    eza
    btop
    bat
    htop
    fd
    ripgrep
    yazi
    xclip

    # -------------------------
    # Core UNIX
    # -------------------------
    coreutils
    curl
    wget
    gnupg
    file
    rsync
    unzip
    zip

    # -------------------------
    # Hardware / Debug
    # -------------------------
    lshw
    pciutils
    usbutils
    lm_sensors

    # -------------------------
    # Network / Connectivity
    # -------------------------
    iwd
    iproute2
    iputils
    traceroute
    dnsutils
    nmap

    # -------------------------
    # Storage / FS
    # -------------------------
    e2fsprogs
    ntfs3g
    dosfstools

    # -------------------------
    # Process / System
    # -------------------------
    procps
    psmisc
    util-linux

    # -------------------------
    # Certificates
    # -------------------------
    cacert

    # -------------------------
    # GUI Applications (global)
    # -------------------------
    firefox
    firefox-developer-edition
    chromium
    brave
    discord
    flameshot
  ];
}
