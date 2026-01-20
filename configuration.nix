# ===========================================================
# NixOS Configuration - Dell Inspiron 1564
# ===========================================================

{ config, pkgs, ... }:

{
  ############################################
  # Imports
  ############################################
  imports = [
    ./hardware-configuration-dell.nix       # Gerado pelo nixos-generate-config
    ./modules/desktop-gnome.nix
    ./modules/system-programs.nix
    ./modules/system-packages.nix
    ./modules/containers/docker.nix
    ./modules/containers/k3s.nix
    ./modules/user-borba.nix
    ./modules/nix-unstable.nix
  ];

  ############################################
  # Hostname
  ############################################
  networking.hostName = "nixos";

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
  # Nix configuration
  ############################################
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ############################################
  # SSH / Firewall
  ############################################
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # Wi-Fi / Bluetooth - Dell Inspiron 1564
  ############################################
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.kernelModules = [ "ssb" "b43" ];
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];

  environment.systemPackages = with pkgs; [
    linux-firmware   # Contém firmware Broadcom e outros
    bluez
    blueman
    pciutils
    usbutils
    rfkill
  ];

  ############################################
  # GNOME Desktop (Wayland)
  ############################################
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "borba";
  services.gnome.core-apps.enable = true;
  services.gnome.gnome-keyring.enable = true;

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "alacritty";
  };

  ############################################
  # Bootloader (GRUB BIOS / Legacy)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];  # Disco principal, ajuste se necessário
  boot.loader.grub.useOSProber = false;

  ############################################
  # Docker + K3s
  ############################################
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  users.users.borba.extraGroups = [ "docker" ];

  # Podman comentado para uso futuro (quando Docker for desligado)
  # virtualisation.podman.enable = true;
  # virtualisation.podman.dockerCompat = true;

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
