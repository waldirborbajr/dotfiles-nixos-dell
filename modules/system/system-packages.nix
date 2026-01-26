# modules/system-packages.nix
# ---
{ pkgs, ... }:

let
  unstablePkgs = pkgs.unstable or pkgs;
in
{
  environment.systemPackages =
    # ----------------------------
    # Stable packages (default)
    # ----------------------------
    (with pkgs; [

      ##########################################
      # Networking / Diagnostics (global)
      ##########################################
      iw
      wirelesstools
      util-linux
      linuxPackages.broadcom_sta

      ##########################################
      # Terminals
      ##########################################
      #alacritty
      #kitty
      gnome-console

      ##########################################
      # Shells & Multiplexers
      ##########################################
      zsh
      # NOTE: tmux configured via home-manager in modules/apps/tmux.nix
      tmuxifier
      zellij

      ##########################################
      # Editors & Development UX
      ##########################################
      helix
      neovim

      ##########################################
      # Git & Developer Workflow
      ##########################################
      #git
      #gh
      lazygit

      ##########################################
      # Virtualization / Kubernetes (non-runtime)
      ##########################################
      # NOTE: k9s, cri-tools, devcontainer moved to devshells
      # QEMU/virt-manager moved to conditional qemu.nix module

      ##########################################
      # Languages / Toolchains
      ##########################################
      gcc
      libgcc
      glibc
      libcxx
      #go
      #gopls
      #rustup
      #rust-analyzer
      #lua
      #lua-language-server

      ##########################################
      # Build essentials (ADD)
      ##########################################
      gnumake
      binutils
      pkg-config
      cmake
      ninja
      meson
      autoconf
      automake
      libtool
      patchelf

      ##########################################
      # Common native deps used in builds (ADD)
      ##########################################
      openssl
      zlib

      ##########################################
      # Nix Tooling (stable)
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
      
      fd
      dust
      ncdu
      zoxide
      atuin
      tldr
      sd
      jq
      fx
      # HTTP client (choose one: httpie is most user-friendly)
      httpie
      fzf
      direnv
      entr
      procs
      # System monitor (btop is most feature-complete)
      btop

      ##########################################
      # Clipboard / Wayland
      ##########################################
      xclip
      wl-clipboard
      clipster

      ##########################################
      # Core UNIX
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
      # Hardware diagnostics
      ##########################################
      lshw
      pciutils
      usbutils
      lm_sensors

      ##########################################
      # Networking tools
      ##########################################
      iwd
      iproute2
      iputils
      traceroute
      dnsutils
      nmap

      ##########################################
      # Storage
      ##########################################
      e2fsprogs
      ntfs3g
      dosfstools

      ##########################################
      # Certificates
      ##########################################
      cacert

      ##########################################
      # GUI
      ##########################################
      flameshot
      chirp
    ])

    # ----------------------------
    # Unstable packages (explicit)
    # ----------------------------
    ++ (with unstablePkgs; [
      clang
      llvm
      lld
      gdb

      # Optional but useful for native debugging alongside gdb (ADD)
      lldb

      # neovim
      # vscode
      # discord
      # anydesk
    ]);
}
