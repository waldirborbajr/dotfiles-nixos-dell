# modules/system/system-packages.nix
# System-level packages (infrastructure, build tools, core utilities)
# User-level apps moved to home-manager (modules/apps/)
{ config, pkgs, lib, ... }:

let
  unstablePkgs = pkgs.unstable or pkgs;
in
{
  config = lib.mkIf config.system-config.systemPackages.enable {
    environment.systemPackages =
      # ----------------------------
      # Stable packages (default)
      # ----------------------------
      (with pkgs; [

        ##########################################
        # Networking / Diagnostics (system-level)
        ##########################################
        iw
        wirelesstools
        util-linux
        linuxPackages.broadcom_sta

        ##########################################
        # Shells (system-level requirement)
        ##########################################
        zsh

        ##########################################
        # Languages / Toolchains (system-level)
        ##########################################
        gcc
        libgcc
        glibc
        libcxx

        ##########################################
        # Build essentials
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
        # Common native deps used in builds
        ##########################################
        openssl
        zlib

        ##########################################
        # Secrets Management
        ##########################################
        sops
        age
        ssh-to-age

        ##########################################
        # Nix Tooling
        ##########################################
        nixd
        nil
        statix
        deadnix
        nixfmt-rfc-style

        ##########################################
        # Core UNIX utilities (system essential)
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
        # Desktop Applications
        ##########################################
        bottles              # Windows application runner
        chromium            # Web browser
        gimp-with-plugins   # Image editor
        # libreoffice       # Office suite
        nom                 # nom is a parser combinators library written in Rust
        qownnotes           # Note-taking application
        vlc                 # Media player

        ##########################################
        # Media Tools
        ##########################################
        ffmpeg              # Video/audio converter and processor
      ])

      # ----------------------------
      # Unstable packages (explicit)
      # ----------------------------
      ++ (with unstablePkgs; [
        ##########################################
        # Compilers & Debuggers (system-level)
        ##########################################
        clang
        llvm
        lld
        gdb
        lldb
      ]);
  };
}
