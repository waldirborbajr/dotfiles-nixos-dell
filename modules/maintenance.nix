{ config, lib, pkgs, ... }:

{
  ############################################
  # Nix — Maintenance & Disk Space Reduction
  ############################################

  # Garbage Collection automática
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 2d";
  };

  ############################################
  # Store optimization
  ############################################

  # Deduplicação via hardlinks
  nix.settings.auto-optimise-store = true;

  # Evita retenção desnecessária
  nix.settings.keep-outputs = false;
  nix.settings.keep-derivations = false;

  ############################################
  # Disk pressure handling (aggressive)
  ############################################

  # Quando o disco começar a encher, Nix age sozinho
  nix.settings.min-free = 1 * 1024 * 1024 * 1024;  # 1 GB
  nix.settings.max-free = 5 * 1024 * 1024 * 1024;  # 5 GB

  ############################################
  # System generations
  ############################################

  # Limita gerações do sistema
  boot.loader.systemd-boot.configurationLimit = 10;

  ############################################
  # systemd sanity
  ############################################

  systemd.timers.nix-gc.wantedBy = [ "timers.target" ];
}
