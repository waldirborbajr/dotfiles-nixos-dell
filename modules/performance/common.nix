{ lib, pkgs, ... }:

{
  ############################################
  # Boot & system noise reduction
  ############################################

#  boot.kernelParams = [
#    "quiet"
#    "loglevel=3"
#    "rd.systemd.show_status=false"
#    "udev.log_level=3"
#  ];

  boot.consoleLogLevel = 0;


  ############################################
  # systemd startup optimizations
  ############################################

  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.systemd-timesyncd.enable = true;

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=10s
    DefaultTimeoutStopSec=10s
  '';


  ############################################
  # Memory & VM tuning (safe defaults)
  ############################################

  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 15;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 15;
  };


  ############################################
  # Nix daemon performance
  ############################################

  nix.settings = {
    auto-optimise-store = true;
    warn-dirty = false;
    keep-outputs = true;
    keep-derivations = true;
  };


  ############################################
  # Journal & logging (reduce IO)
  ############################################

  services.journald.extraConfig = ''
    SystemMaxUse=200M
    RuntimeMaxUse=100M
    MaxRetentionSec=7day
    Compress=yes
  '';


  ############################################
  # Disable unnecessary background services
  ############################################

  services.udisks2.enable = lib.mkDefault true;
  services.fwupd.enable = lib.mkDefault false;
  services.printing.enable = lib.mkDefault false;


  ############################################
  # DNS (faster, less blocking)
  ############################################

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    fallbackDns = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };


  ############################################
  # ZRAM (safe for low/mid RAM systems)
  ############################################

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

}
