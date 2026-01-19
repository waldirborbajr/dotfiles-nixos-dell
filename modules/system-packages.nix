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
    unstable.virt-manager      # Latest features, Wayland support

    ##########################################
    # Containers / Cloud / Kubernetes
    ##########################################
    docker
    docker-compose
    lazydocker

    # Kubernetes / k3s
    k9s                        # Kubernetes CLI TUI

    # Podman (rootless) - comentado enquanto Docker está ativo
    # podman
    # podman-compose
    # buildah
    # skopeo
    # cri-tools
    # Motivo: Podman não deve ser ativado junto com Docker, pois dockerCompat entra em conflito.
    # Para ativar no futuro, descomente estas linhas e comente Docker.

    ##########################################
    # Virtualization (clients & tools)
    ##########################################
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
    unstable.neovim          # Latest editor features
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
    unstable.gdb           # Latest debugger features
    unstable.clang         # Latest compiler features
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
    wl-clipboard            # Wayland clipboard
    clipster
    greenclip

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
    chirp
  ];
}
