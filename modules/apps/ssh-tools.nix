# modules/apps/ssh-tools.nix
# SSH utilities and enhanced remote terminal tools
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.ssh-tools.enable {
    home.packages = with pkgs; [
      # Enhanced remote terminal tools
      mosh # Mobile shell - better than SSH for unstable connections
      eternal-terminal # Persistent SSH sessions
      
      # SSH utilities
      sshfs # Mount remote filesystems over SSH
      ssh-copy-id # Copy SSH keys to remote servers
      sshpass # Non-interactive SSH password authentication
      
      # SSH key management
      ssh-audit # SSH server security audit
      ssh-tools # Collection of SSH tools
    ];

    # SSH configuration (managed by home-manager)
    programs.ssh = {
      enable = true;
      
      # Connection optimization
      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/%r@%h:%p";
      controlPersist = "10m";
      
      # Security settings
      hashKnownHosts = true;
      
      # Common settings
      extraConfig = ''
        # Keep connections alive
        ServerAliveInterval 60
        ServerAliveCountMax 3
        
        # Fast connection
        Compression yes
        
        # Reuse connections
        ControlPersist yes
      '';
    };

    # Create socket directory for SSH multiplexing
    home.file.".ssh/sockets/.keep".text = "";

    # Shell aliases for SSH tools
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      # Mosh shortcuts
      m = "mosh";
      
      # SSHFS mount helpers
      sshm = "sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3";
      sshu = "fusermount -u"; # Unmount SSHFS
      
      # SSH key management
      sshkey = "ssh-keygen -t ed25519 -C";
      sshcopy = "ssh-copy-id";
      
      # Quick SSH audit
      sshaudit = "ssh-audit";
    };
  };
}
