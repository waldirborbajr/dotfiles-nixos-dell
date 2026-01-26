# modules/performance/macbook.nix
# MacBook-specific performance optimizations
{ lib, pkgs, ... }:

{
  ############################################
  # Boot Optimizations
  ############################################
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "elevator=mq-deadline"  # Optimal for SSD
    "intel_pstate=active"   # Modern Intel P-state driver
  ];

  # Faster boot with systemd in initrd
  boot.initrd.systemd.enable = true;

  ############################################
  # CPU Governor (Performance for desktop use)
  ############################################
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  ############################################
  # TLP Power Management (Laptop-specific)
  ############################################
  services.tlp = {
    enable = true;
    settings = {
      # CPU
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;
      
      # Platform
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      
      # Disk
      DISK_DEVICES = "sda";
      DISK_APM_LEVEL_ON_AC = "254";
      DISK_APM_LEVEL_ON_BAT = "128";
      DISK_IOSCHED = "mq-deadline";
      
      # PCIe
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      
      # USB autosuspend
      USB_AUTOSUSPEND = 1;
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_BTUSB = 0;
      USB_EXCLUDE_PHONE = 0;
      USB_EXCLUDE_PRINTER = 1;
      USB_EXCLUDE_WWAN = 0;
      
      # SATA link power management
      SATA_LINKPWR_ON_AC = "max_performance";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
    };
  };

  ############################################
  # Thermal Management (thermald)
  ############################################
  services.thermald.enable = true;

  ############################################
  # IRQ Balance (multi-core optimization)
  ############################################
  services.irqbalance.enable = true;

  ############################################
  # Transparent Huge Pages
  ############################################
  boot.kernel.sysctl = {
    # THP for better memory performance
    "vm.nr_hugepages" = 128;
    
    # Network buffer tuning
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.tcp_fastopen" = 3;
    
    # Writeback tuning for SSD
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.dirty_expire_centisecs" = 3000;
  };

  ############################################
  # Containers disabled by default
  ############################################
  systemd.services.k3s.wantedBy = lib.mkForce [];

  ############################################
  # Fast Boot: Disable slow services
  ############################################
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.plymouth-quit-wait.enable = lib.mkDefault false;
}
