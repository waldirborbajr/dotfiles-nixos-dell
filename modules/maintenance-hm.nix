{ config, lib, pkgs, ... }:

{
  ############################################
  # Home Manager profiles cleanup (safe)
  ############################################

  systemd.services.hm-profile-gc = {
    description = "Garbage collect old Home Manager profiles";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "hm-profile-gc" ''
        set -e

        HM_PROFILE="/nix/var/nix/profiles/per-user/${config.users.users.borba.name}/home-manager"

        if [ -e "$HM_PROFILE" ]; then
          echo "Cleaning old Home Manager generations..."
          nix-env --profile "$HM_PROFILE" --delete-generations +3 || true
        else
          echo "No Home Manager profile found, skipping."
        fi
      '';
    };
  };

  systemd.timers.hm-profile-gc = {
    description = "Periodic cleanup of Home Manager profiles";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
