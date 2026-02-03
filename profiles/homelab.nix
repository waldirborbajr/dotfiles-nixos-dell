# profiles/homelab.nix
# Ultra-minimal headless server profile for HomeLab
# Optimized for Docker containers and remote management
{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/system
    ../modules/users/borba.nix
    ../modules/virtualization/docker.nix
    ../modules/features/tailscale.nix
  ];

  # Enable minimal system components
  system-config = {
    base.enable = true;
    networking.enable = true;
    ssh.enable = true;
    # Disable non-essential services for headless server
    audio.enable = lib.mkForce false;
    fonts.enable = lib.mkForce false;
  };

  # ==========================================
  # Docker Configuration
  # ==========================================
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    storageDriver = "overlay2";
  };

  # ==========================================
  # Tailscale VPN (System-level)
  # ==========================================
  features.tailscale.enable = true;

  # ==========================================
  # Disable GUI Components
  # ==========================================
  services.xserver.enable = lib.mkForce false;
  sound.enable = lib.mkForce false;
  hardware.pulseaudio.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;
  boot.plymouth.enable = lib.mkForce false;

  # ==========================================
  # Emergency TTY Access
  # ==========================================
  services.getty.autologinUser = "borba";

  # ==========================================
  # zRAM for better performance
  # ==========================================
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # ==========================================
  # SSH Hardening
  # ==========================================
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # ==========================================
  # System Packages (Minimal)
  # ==========================================
  environment.systemPackages = with pkgs; [
    # Docker tools
    docker-compose
    lazydocker

    # System monitoring
    htop
    btop
    iotop
    ncdu

    # Network tools
    tailscale
    curl
    wget
    tcpdump
    nmap

    # Essential CLI tools
    vim
    git
    tmux
    tree
    unzip
    zip

    # File management
    rsync
    rclone
  ];

  # ==========================================
  # Systemd tmpfiles - Create directories
  # ==========================================
  systemd.tmpfiles.rules = [
    "d /home/borba/homelab 0755 borba users -"
    "d /home/borba/homelab/config 0755 borba users -"
    "d /mnt/media 0755 borba users -"
    "d /mnt/media/movies 0755 borba users -"
    "d /mnt/media/tvshows 0755 borba users -"
    "d /mnt/media/music 0755 borba users -"
  ];

  # ==========================================
  # Firewall Configuration
  # ==========================================
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # Tailscale handled separately
      80      # HTTP (Caddy)
      443     # HTTPS (Caddy)
      8080    # Heimdall
      9000    # Portainer
      19999   # Netdata (optional)
      32400   # Plex
    ];
    allowedUDPPorts = [
      443     # HTTP/3 (Caddy)
    ];
    # Trust Tailscale interface
    trustedInterfaces = [ "tailscale0" ];
  };

  # ==========================================
  # Power Management
  # ==========================================
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
