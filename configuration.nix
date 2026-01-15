# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  ############################################
  # Bootloader
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  ############################################
  # Networking
  ############################################
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  ############################################
  # Nix Garbage Collection (max 2 days)
  ############################################
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 2d";
  };

  ############################################
  # Locale / Time
  ############################################
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  ############################################
  # X11 + GNOME
  ############################################
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  console.keyMap = "br-abnt2";

  ############################################
  # Printing / Audio
  ############################################
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################################
  # User
  ############################################
  users.users.borba = {
    isNormalUser = true;
    description = "BORBA JR W";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      neovim
    ];
  };

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "borba";

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ############################################
  # Programs
  ############################################
  programs = {
    firefox.enable = true;
    zsh.enable = true;

    ##########################################
    # Modern CLI tools (native NixOS modules)
    ##########################################

    ripgrep.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  ############################################
  # Default Terminal
  ############################################
  environment.variables = {
    TERMINAL = "alacritty";
  };

  xdg.mime.defaultApplications = {
    "application/x-terminal-emulator" = "alacritty.desktop";
  };

  ############################################
  # SUDO: no password ONLY for nixos-rebuild
  ############################################
  security.sudo.extraRules = [
    {
      users = [ "borba" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nixpkgs.config.allowUnfree = true;

  ############################################
  # System Packages (no duplicates)
  ############################################
  environment.systemPackages = with pkgs; [
    wget
    coreutils
    git
    gh
    lazygit
    stow
    tmux
    xclip
    lshw
    iwd
    rofi
    keepassxc
    waybar
    networkmanagerapplet

    # Modern CLI tools
    eza
    btop
    htop
    fd

    # Go
    go
    gopls

    # Rust
    rustup
    cargo
    rust-analyzer

    # Nix
    nixd
    nil
    statix
    deadnix
    nixfmt-rfc-style
  ];

  ############################################
  # Fonts
  ############################################
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.terminess-ttf
      nerd-fonts.blex-mono
      ibm-plex
      openmoji-color
    ];

    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "IBM Plex Sans" ];
      serif = [ "IBM Plex Serif" ];
      emoji = [ "OpenMoji Color" ];
    };

    enableDefaultFonts = true;
  };

  ############################################
  # Services
  ############################################
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # Nix Features
  ############################################
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "25.11";
}
