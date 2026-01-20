{ pkgs, ... }:

let
  unstable = pkgs.unstable or pkgs;
in
{
  environment.systemPackages = with pkgs; [

    ##########################################
    # Terminals
    ##########################################
    alacritty          # GPU-accelerated terminal
    kitty              # Feature-rich terminal
    gnome-console      # GNOME default terminal

    ##########################################
    # Shells & Multiplexers
    ##########################################
    zsh                # Primary shell
    fish               # Alternative shell
    tmux               # Terminal multiplexer
    tmuxifier          # tmux session manager
    zellij             # Modern tmux alternative

    ##########################################
    # Editors & Development UX
    ##########################################
    unstable.neovim    # Neovim (unstable for faster updates)
    helix              # Modal editor, LSP-first
    unstable.vscode
    unstable.vscode-extensions.ms-vscode-remote.remote-containers

    ##########################################
    # Git & Developer Workflow
    ##########################################
    git
    gh                 # GitHub CLI
    lazygit            # TUI for git
    commitizen         # Conventional commits helper
    devcontainer       # Dev container tooling

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
    # Build & Debug Tooling
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
    nixd               # Nix language server
    nil                # Alternative Nix LSP
    statix             # Static analysis for Nix
    deadnix            # Find unused Nix code
    nixfmt-rfc-style   # Nix formatter

    ##########################################
    # Modern CLI Utilities (Shell-first / DevOps)
    ##########################################
    eza                # ls replacement
    bat                # cat replacement
    fd                 # find replacement
    ripgrep            # grep replacement
    yazi               # Terminal file manager
    dust               # du replacement
    ncdu               # Disk usage analyzer
    zoxide             # Smarter cd
    atuin              # Shell history with sync
    tldr               # Simplified man pages
    sd                 # sed replacement
    jq                 # JSON processor
    fx                 # Interactive JSON viewer
    httpie             # Modern HTTP client
    curlie             # curl + httpie hybrid
    fzf                # Fuzzy finder
    direnv             # Per-directory environments
    entr               # Run commands on file changes
    procs              # ps replacement
    bottom             # Advanced system monitor
    btop               # Resource monitor
    htop

    ##########################################
    # Clipboard / Wayland Utilities
    ##########################################
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
    tree
    stow

    ##########################################
    # Hardware / System Diagnostics
    ##########################################
    lshw
    pciutils
    usbutils
    lm_sensors

    ##########################################
    # Networking
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
