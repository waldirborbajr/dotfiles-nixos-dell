# modules/desktops/niri/input.nix
# Input configuration (keyboard, touchpad, mouse, etc)
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  
  inputConfig = ''
    // ============================================
    // INPUT CONFIGURATION
    // ============================================
    input {
      keyboard {
        xkb {
          layout "us"
          variant ""
        }
        repeat-delay 250
        repeat-rate 35
        track-layout "global"
        // Enable numlock on startup
        numlock
      }

      touchpad {
        tap
        natural-scroll
        dwt
        dwtp
        accel-speed 0.3
        accel-profile "adaptive"
        scroll-method "two-finger"
        click-method "clickfinger"
      }

      mouse {
        accel-speed 0.0
        accel-profile "flat"
      }

      tablet {
        map-to-output "eDP-1"
      }

      touch {
        map-to-output "eDP-1"
      }

      trackpoint {
        accel-speed 0.2
        accel-profile "adaptive"
      }

      // Focus windows and outputs automatically when moving the mouse into them
      // Setting max-scroll-amount="0%" makes it work only on windows already fully on screen
      focus-follows-mouse max-scroll-amount="0%"
      workspace-auto-back-and-forth
    }
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/input.kdl".text = inputConfig;
}
