{ pkgs, ... }:

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
    lazydocker

    # Kubernetes CLI/TUI
    k9s

    podman
    podman-compose
    buildah
    skopeo
    cri-tools
    lazypodman

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
    unstable.neovim
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
    xclip          # Clipboard X11
    wl-clipboard   # Clipboard Wayland
    clipster       # Optional clipboard manager
    greenclip      # Optional clipboard manager

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
  # Clipboard helper aliases (optional)
  ############################################
  # This adds shell functions to make wl-clipboard / xclip usage seamless.
  # Does not override existing zsh aliases; the user can still define their own.
  environment.etc."profile.d/clipboard.sh".text = ''
    # Detect Wayland vs X11
    if command -v wl-copy >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
      alias copy='wl-copy'
      alias paste='wl-paste'
    elif command -v xclip >/dev/null 2>&1; then
      alias copy='xclip -selection clipboard'
      alias paste='xclip -selection clipboard -o'
    fi
  '';
}
