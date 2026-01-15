{ config, pkgs, ... }:

{
  # ────────────────────────────────────────────────
  # Boot (deixe o device em cada host)
  # ────────────────────────────────────────────────
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;

  # ────────────────────────────────────────────────
  # Networking (hostname será sobrescrito por host)
  # ────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ────────────────────────────────────────────────
  # Nix
  # ────────────────────────────────────────────────
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 2d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ────────────────────────────────────────────────
  # Locale / Time
  # ────────────────────────────────────────────────
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS      = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT  = "pt_BR.UTF-8";
    LC_MONETARY     = "pt_BR.UTF-8";
    LC_NAME         = "pt_BR.UTF-8";
    LC_NUMERIC      = "pt_BR.UTF-8";
    LC_PAPER        = "pt_BR.UTF-8";
    LC_TELEPHONE    = "pt_BR.UTF-8";
    LC_TIME         = "pt_BR.UTF-8";
  };

  # ────────────────────────────────────────────────
  # Wayland + GNOME
  # ────────────────────────────────────────────────
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # services.xserver.xkb.layout = "br";

  # console.keyMap = "br-abnt2";

  # ────────────────────────────────────────────────
  # Printing + Audio
  # ────────────────────────────────────────────────
  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ────────────────────────────────────────────────
  # Environment
  # ────────────────────────────────────────────────
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "alacritty";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  # ────────────────────────────────────────────────
  # User (parte básica – pacotes vão para home-manager)
  # ────────────────────────────────────────────────
  users.users.borba = {
    isNormalUser = true;
    description = "BORBA JR W";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  users.users.devops = {
    isNormalUser = true;
    description = "DevOps User";
    extraGroups = [
      "networkmanager"
      "wheel"          # sudo
      "docker"         # se usar docker
      "podman"         # alternativa comum em DevOps
      "libvirtd"       # virtualização (opcional)
      "kvm"
    ];
    shell = pkgs.zsh;  # ou bash/fish se preferir
    # packages = [ ... ];  ← NÃO coloque pacotes aqui! Use home-manager para isolar
  };

  # Auto-login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "borba";

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Sudo sem senha só pro nixos-rebuild
  security.sudo.extraRules = [{
    users = [ "borba" ];
    commands = [{
      command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  # ────────────────────────────────────────────────
  # Docker
  # ────────────────────────────────────────────────
  virtualisation.docker.enable = true;

  # SSH (opcional)
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.11";
}