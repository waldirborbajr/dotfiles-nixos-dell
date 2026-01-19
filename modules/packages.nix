{ pkgs, ... }:

{
  ############################################
  # Programs (system-level only)
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
  # Core System Packages
  ############################################
  environment.systemPackages = with pkgs; [
    # Terminais
    alacritty
    kitty

    # Shell / Multiplexador
    zsh
    tmux
    tmuxifier
    stow

    # Editor
    neovim
    lazygit

    # Containers
    docker
    docker-compose

    # Linguagens
    go
    gopls

    rustup
    rust-analyzer

    # Nix tooling
    nixd
    nil
    statix
    deadnix
    nixfmt-rfc-style

    # CLI moderna
    eza
    btop
    bat
    htop
    fd
    ripgrep
    yazi

    # Utilitários
    wget
    git
    gh
    coreutils
    lshw

    ############################################
    # Core UNIX / Build
    ############################################
    coreutils
    gnumake
    wget
    curl
    gnupg

    ############################################
    # Toolchain — Clang / LLVM (básico)
    ############################################
    clang
    llvm
    lld

    ############################################
    # Hardware / System Debug
    ############################################
    lshw
    pciutils
    usbutils
    lm_sensors

    ############################################
    # Network / Connectivity
    ############################################
    iwd
    iproute2
    iputils
    traceroute
    dnsutils
    nmap

    ############################################
    # Storage / Filesystem
    ############################################
    e2fsprogs
    ntfs3g
    dosfstools

    ############################################
    # Process / System inspection
    ############################################
    procps
    psmisc
    util-linux

    ############################################
    # Archive / Recovery
    ############################################
    unzip
    zip
    rsync
    file

    ############################################
    # Certificates / SSL
    ############################################
    cacert


  ];
}
