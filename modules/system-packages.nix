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
      alacritty
      kitty
      gnome-console

      ##########################################
      # Shells & Multiplexers
      ##########################################
      zsh
      fish
      tmux
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
      git
      gh
      lazygit
      commitizen
      devcontainer

      ##########################################
      # Virtualization / Kubernetes (non-runtime)
      ##########################################
      k9s
      cri-tools

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
      lua
      lua-language-server

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
      bat
      fd
      ripgrep
      yazi
      dust
      ncdu
      zoxide
      atuin
      tldr
      sd
      jq
      fx
      httpie
      curlie
      fzf
      direnv
      entr
      procs
      bottom
      btop
      htop

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
