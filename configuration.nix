{ config, pkgs, ... }:

{
  ############################################
  # Imports
  ############################################
  imports = [
    ./hardware-configuration-dell.nix
    ./modules/desktop-gnome.nix
    ./modules/system-packages.nix
    ./modules/kernel-tuning.nix
    ./modules/containers/docker.nix
    ./modules/containers/k3s.nix
    ./modules/maintenance.nix
    ./modules/user-borba.nix
  ];

  ############################################
  # Bootloader
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";  # Ajuste conforme seu disco root
  boot.loader.grub.useOSProber = true;

  ############################################
  # Networking
  ############################################
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  ############################################
  # Wi-Fi / Bluetooth (Dell Inspiron 1564)
  ############################################
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Força carregamento dos módulos corretos
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.kernelModules = [ "ssb" "b43" ];

  # Evita conflitos com outros drivers Broadcom
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];

  environment.systemPackages = with pkgs; [
    linux-firmware
    bluez
    blueman
    b43-fwcutter
    pciutils
    usbutils
    wget
    git
    coreutils
    alacritty
    tmux
    neovim
  ];

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
  # Users
  ############################################
  users.users.borba = {
    isNormalUser = true;
    description = "BORBA JR W";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ neovim ];
  };

  ############################################
  # Auto-login
  ############################################
  services.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  ############################################
  # Console / Keymap
  ############################################
  console.keyMap = "br-abnt2";
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

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
  # Wayland / GNOME
  ############################################
  services.xserver.enable = true;
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.desktopManager.gnome.enable = true;

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "alacritty";
    TMUXIFIER_LAYOUT_PATH = "$HOME/.config/tmuxifier/layouts";
  };

  ############################################
  # XDG Portals
  ############################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  ############################################
  # System services tweaks
  ############################################
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  ############################################
  # Nix / Unfree
  ############################################
  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
