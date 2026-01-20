{ pkgs, ... }:

let
  unstable = pkgs.unstable or pkgs;
in
{
  environment.systemPackages = with pkgs; [

    ##########################################
    # Terminals
    ##########################################
    alacritty
    kitty
    gnome-console

    ##########################################
    # Shells / Multiplexers
    ##########################################
    zsh
    fish
    tmux
    tmuxifier
    stow
    tree

    ##########################################
    # Editors / IDEs / Git
    ##########################################
    unstable.neovim
    unstable.vscode
    unstable.vscode-extensions.ms-vscode-remote.remote-containers
    lazygit
    git
    gh
    devcontainer

    ##########################################
    # Notes / Knowledge Base
    ##########################################
    unstable.obsidian

    ##########################################
    # Containers / Virtualization / Kubernetes
    ##########################################
    docker
    docker-compose
    docker-buildx
    lazydocker
    podman
    podman-compose
    buildah
    skopeo
    cri-tools
    k9s

    virt-manager
    virt-viewer
    qemu
    virtio-win
    spice
    spice-gtk
    spice-protocol

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
    procps
    psmisc
    util-linux

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
    # Certificates / SSL
    ##########################################
    cacert

    ##########################################
    # GUI Applications
    ##########################################
    firefox
    chromium
    brave
    unstable.discord
    flameshot
    chirp
    unstable.anydesk
  ];
}
