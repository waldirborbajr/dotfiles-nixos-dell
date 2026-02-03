# hosts/dell-homelab.nix
# HomeLab Configuration - Headless Server
# Docker-based services: Portainer, Plex, Caddy, Heimdall
# Preserves original dell.nix for testing/fallback
{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.11";

  ############################################
  # Hardware & Performance & Profile
  ############################################
  imports = [
    ../hardware/dell.nix
    ../hardware/performance/dell.nix
    ../hardware/dell-hw-config.nix
    ../profiles/homelab.nix  # Headless HomeLab profile
  ];

  ############################################
  # Host Identity
  ############################################
  networking.hostName = "dell-homelab";

  ############################################
  # Bootloader (Legacy BIOS)
  ############################################
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  ############################################
  # Keyboard Layout (Dell)
  ############################################
  console.keyMap = "br-abnt2";

  ############################################
  # HomeLab Docker Stack Files
  ############################################
  # Create docker-compose.yml and Caddyfile in /home/borba/homelab
  environment.etc."homelab/docker-compose.yml" = {
    text = builtins.readFile ../examples/homelab-docker-compose.yml;
    mode = "0644";
  };

  environment.etc."homelab/Caddyfile" = {
    text = builtins.readFile ../examples/homelab-Caddyfile;
    mode = "0644";
  };

  environment.etc."homelab/README.md" = {
    text = builtins.readFile ../examples/homelab-README.md;
    mode = "0644";
  };

  # Symlink to home directory for easy access
  system.activationScripts.homelabSetup = ''
    mkdir -p /home/borba/homelab
    
    # Copy files if they don't exist (preserves user modifications)
    if [ ! -f /home/borba/homelab/docker-compose.yml ]; then
      cp /etc/homelab/docker-compose.yml /home/borba/homelab/
    fi
    
    if [ ! -f /home/borba/homelab/Caddyfile ]; then
      cp /etc/homelab/Caddyfile /home/borba/homelab/
    fi
    
    if [ ! -f /home/borba/homelab/README.md ]; then
      cp /etc/homelab/README.md /home/borba/homelab/
    fi
    
    # Set ownership
    chown -R borba:users /home/borba/homelab
  '';

  ############################################
  # Additional Notes
  ############################################
  # After deployment:
  # 1. SSH into the server: ssh borba@dell-homelab
  # 2. Navigate to homelab: cd ~/homelab
  # 3. Start stack: docker-compose up -d
  # 4. Access via Tailscale:
  #    - Heimdall: http://dell-homelab.tail-xxxxx.ts.net:8080
  #    - Portainer: http://dell-homelab.tail-xxxxx.ts.net:9000
  #    - Plex: http://dell-homelab.tail-xxxxx.ts.net:32400/web
}
