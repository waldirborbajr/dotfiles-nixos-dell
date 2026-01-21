{ lib, ... }:

{
  ############################################
  # Boot (EFI)
  ############################################

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
  ];


  ############################################
  # CPU (aggressive power saving)
  ############################################

  powerManagement.cpuFreqGovernor = "powersave";


  ############################################
  # Disk / IO (MacBooks suffer more here)
  ############################################

#  boot.kernel.sysctl = {
#    "vm.swappiness" = 20;
#  };


  ############################################
  # Containers disabled by default
  ############################################

  virtualisation.docker.enable = lib.mkForce false;
  systemd.services.k3s.wantedBy = lib.mkForce [];
}
