{ pkgs, ... }:

let
  # Canal unstable com unfree permitido
  unstable = import <nixpkgs-unstable> {
    config = { allowUnfree = true; };
  };
in
{
  ############################################
  # Programs / System-level
  ############################################
  programs = {
    zsh.enable = true;
    firefox.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  ############################################
  # System Packages (consolidado)
  ############################################
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
    # Containers / Virtualization / Cloud / Kubernetes
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
    anydesk
  ];
}
