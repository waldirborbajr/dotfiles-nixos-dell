{ lib, pkgs, ... }:

{
  ############################################
  # Kernel
  ############################################

  # Kernel padrão estável, mas com tuning desktop
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ############################################
  # Kernel parameters (boot speed + latency)
  ############################################
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_level=3"
    "vt.global_cursor_default=0"
    "nowatchdog"
    "mitigations=auto"
  ];

  ############################################
  # Filesystems / IO
  ############################################
  boot.tmp.cleanOnBoot = true;

  # Reduce disk IO at boot
  services.journald.extraConfig = ''
    SystemMaxUse=200M
    RuntimeMaxUse=50M
  '';

  ############################################
  # CPU / Power (Laptop-friendly)
  ############################################
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  services.power-profiles-daemon.enable = true;

  ############################################
  # systemd boot optimizations
  ############################################
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-udev-settle.enable = false;

  ############################################
  # ZRAM (faster than swap on laptops)
  ############################################
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };
}
