{ pkgs, ... }:

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
    k9s             # Kubernetes CLI TUI

    podman
    podman-compose
    buildah
    skopeo
    cri-tools
    unstable.lazypodman      # Latest features for Podman

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

    ##########################################
    # Clipboard / copy-paste support
    ##########################################
    xclip                 # X11 clipboard
    wl-clipboard           # Wayland clipboard
    clipster               # Clipboard manager
    greenclip              # Clipboard manager daemon

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

  ############################################
  # Clipboard Aliases (safe, X11/Wayland)
  ############################################
  environment.etc."profile.d/clipboard.sh".text = ''
    #!/usr/bin/env sh
    # Auto-select X11 or Wayland clipboard commands
    if [ -n "$WAYLAND_DISPLAY" ]; then
      export CLIP_CMD="wl-copy"
      export PASTE_CMD="wl-paste"
    else
      export CLIP_CMD="xclip -selection clipboard"
      export PASTE_CMD="xclip -selection clipboard -o"
    fi
  '';
}
