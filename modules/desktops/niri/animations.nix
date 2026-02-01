# modules/desktops/niri/animations.nix
# Animation configuration
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  animationsConfig = ''
    // ============================================
    // ANIMATIONS
    // ============================================
    animations {
      slowdown 1.0
      
      workspace-switch {
        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
      }
      
      horizontal-view-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }
      
      window-open {
        duration-ms 150
        curve "ease-out-expo"
      }
      
      window-close {
        duration-ms 150
        curve "ease-out-quad"
      }
      
      window-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }
      
      window-resize {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }
      
      config-notification-open-close {
        spring damping-ratio=0.6 stiffness=1000 epsilon=0.001
      }
    }

    // ============================================
    // DEBUG (Performance monitoring)
    // ============================================
    debug {
      render-drm-device "/dev/dri/renderD128"
      
      // Uncomment to enable visual debug
      // dri-device "/dev/dri/card0"
      // disable-cursor-plane
      // wait-for-frame-completion-before-queueing
    }
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/animations.kdl".text = animationsConfig;
}
