{ pkgs, ... }:

let
  # Canal unstable (adicionado via nix-channel)
  unstable = import <nixpkgs-unstable> {};
in
{
  ############################################
  # System Packages (global / hardware-agnostic)
  ############################################
  environment.systemPackages = with pkgs; [

    ############################################
    # Virtualization (hardware-agnostic)
    ############################################
    unstable.virt-manager

    ##########################################
    # Containers / Cloud / Kubernetes
    ##########################################
    docker
    docker-compose
    docker-buildx
    lazydocker

    # Kubernetes
    k9s

    ##########################################
    # Virtualization (clients & tools)
    ##########################################
    virt-viewer
    qemu
    virtio-win
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
    # Editors / IDEs / Git
    ##########################################
    unstable.neovim
    vscode
    vscode-extensions.ms-vscode-remote.remote-containers
    lazygit
    git
    gh

    ##########################################
    # Notes / Knowledge Base
    ##########################################
    obsidian

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
    unstable.gdb
    unstable.clang
    unstable.llvm
    unstable.lld

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
    wl-clipboard
    clipster
    haskellPackages.greenclip

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
    # GUI Applications
    ##########################################
    firefox
    chromium
    brave
    discord
    flameshot
    chirp
    anydesk
  ];
}
