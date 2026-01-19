{ pkgs, ... }:

{
  ############################################
  # System Packages (global / hardware-agnostic)
  ############################################
  environment.systemPackages = with pkgs; [

    ##########################################
    # Containers / Cloud / Kubernetes
    ##########################################
    docker
    docker-compose
    lazydocker

    podman
    podman-compose
    buildah
    skopeo
    cri-tools

    k3s

    ##########################################
    # Virtualization (clients & tools)
    ##########################################
    virt-manager
    virt-viewer
    qemu
    win-virtio

    spice
    spice-gtk
    spice-protocol

    ##########################################
    # System Information
    ##########################################
    microfetch

    ##########################################
    # Terminals
    ##########################################
    alacritty
    kitty

    ##########################################
    # Shells / Multiplexers
    ##########################################
    zsh
    fish
    tmux
    tmuxifier
    stow

    ##########################################
    # Editors / Git
    ##########################################
    neovim
    lazygit
    git
    gh

    ##########################################
    # Languages / Toolchains
    ##########################################
    gcc
    libgcc
    glibc
    libcxx

    go
    gopls

    rustup
    rust-analyzer

    ##########################################
    # Build / Development Tools
    ##########################################
    cmake
    gnumake
    libtool
    libvterm
    gdb

    clang
    llvm
    lld

    ##########################################
    # Nix Tooling
    ##########################################
    nixd
    nil
    statix
    deadnix
    nixfmt-rfc-style

    ##########################################
    # Modern CLI Utilities
    ##########################################
    eza
    btop
    bat
    htop
    fd
    ripgrep
    yazi
    xclip

    ##########################################
    # Core UNIX Utilities
    ##########################################
    coreutils
    curl
    wget
    gnupg
    file
    rsync
    unzip
    zip

    ##########################################
    # Hardware / System Debug
    ##########################################
    lshw
    pciutils
    usbutils
    lm_sensors

    ##########################################
    # Network / Connectivity
    ##########################################
    iwd
    iproute2
    iputils
    traceroute
    dnsutils
    nmap

    ##########################################
    # Storage / Filesystems
    ##########################################
    e2fsprogs
    ntfs3g
    dosfstools

    ##########################################
    # Process / System Inspection
    ##########################################
    procps
    psmisc
    util-linux

    ##########################################
    # Certificates / SSL
    ##########################################
    cacert

    ##########################################
    # GUI Applications (global)
    ##########################################
    firefox
    firefox-developer-edition
    chromium
    brave
    discord
    flameshot
    anydesk
    chirp
  ];
}
