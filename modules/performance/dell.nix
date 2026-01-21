{ lib, ... }:

{
  ############################################
  # Boot performance
  ############################################

  # Faster and more parallel initrd
  boot.initrd.systemd.enable = true;

  # Reduce boot verbosity and overhead
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
  ];

  # Avoid unnecessary waits during boot
  # systemd.services.systemd-udev-settle.enable = false;


  ############################################
  # CPU scheduling & memory behavior
  ############################################

  # Best balance for older CPUs (desktop use)
  powerManagement.cpuFreqGovernor = "schedutil";

  # Reduce memory pressure and disk thrashing
#  boot.kernel.sysctl = {
#    "vm.swappiness" = 10;
#  };


  ############################################
  # Nix build performance (avoid system stalls)
  ############################################

  nix.settings = {
    max-jobs = 2;
    cores = 2;
  };


  ############################################
  # Container services (do NOT auto-start)
  ############################################

  # Keep Docker installed but do not start at boot
  virtualisation.docker.enableOnBoot = lib.mkForce false;

  # Keep K3s installed but do not auto-start
  systemd.services.k3s.wantedBy = lib.mkForce [];


  ############################################
  # Desktop / GNOME performance hints
  ############################################

  environment.sessionVariables = {
    # Reduce Mutter overhead on older Intel iGPU
    MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
    MUTTER_DEBUG_FORCE_KMS_MODE = "simple";
  };
}
