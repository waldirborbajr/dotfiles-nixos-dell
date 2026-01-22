# modules/performance/dell.nix
{ lib, ... }:

{
  ############################################
  # Dell: No display manager, startx only
  ############################################
  services.xserver.displayManager.startx.enable = true;

  # Make sure no DM is enabled on Dell
  services.displayManager.gdm.enable = false;

  # (Optional, redundant but harmless)
  services.xserver.displayManager.lightdm.enable = false;

  ############################################
  # VM / memory tuning
  ############################################
  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 10;
    "vm.dirty_ratio" = lib.mkDefault 10;
  };

  ############################################
  # ZRAM: already defined in performance/common.nix
  # If you want Dell-specific tuning, override memoryPercent:
  ############################################
  zramSwap.memoryPercent = lib.mkDefault 35;
}
