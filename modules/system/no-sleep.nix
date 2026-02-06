# modules/system/no-sleep.nix
# no-sleep: disable suspend/hibernate when enabled
{ config, lib, ... }:

{
  options.system-config.noSleep = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable sleep, suspend, and hibernate";
    };
  };

  config = lib.mkIf config.system-config.noSleep.enable {
    # no-sleep: block all sleep/suspend targets
    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';

    # Prevent logind from suspending on idle
    services.logind.extraConfig = ''
      IdleAction=ignore
    '';
  };
}
