# modules/desktops/niri/config.nix
# Main Niri config.kdl file - imports all modular configurations
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  # Applications
  term = "alacritty";
  menu = "fuzzel";
  browser = "firefox";
  fileManager = "yazi";

  mainConfigKdl = ''
 // This config is in the KDL format: https://kdl.dev
// "/-" comments out the following node.
// Check the wiki for a full description of the configuration:
// https://yalter.github.io/niri/Configuration:-Introduction

// Input device configuration.
// Find the full list of options on the wiki:
// https://yalter.github.io/niri/Configuration:-Input
input {
    keyboard {
        xkb {
            // You can set rules, model, layout, variant and options.
            // For more information, see xkeyboard-config(7).

            // For example:
            // layout "us,ru"
            // options "grp:win_space_toggle,compose:ralt,ctrl:nocaps"

            // If this section is empty, niri will fetch xkb settings
            // from org.freedesktop.locale1. You can control these using
            // localectl set-x11-keymap.
        }
        repeat-delay 200
        repeat-rate 35
        // Enable numlock on startup, omitting this setting disables it.
        numlock
    }

    // Next sections include libinput settings.
    // Omitting settings disables them, or leaves them at their default values.
    // All commented-out settings here are examples, not defaults.
    touchpad {
        // off
        tap
        // dwt
        // dwtp
        // drag false
        // drag-lock
        natural-scroll
        // accel-speed 0.2
        // accel-profile "flat"
        // scroll-method "two-finger"
        // disabled-on-external-mouse
    }

    mouse {
        // off
        // natural-scroll
        // accel-speed 0.2
        // accel-profile "flat"
        // scroll-method "no-scroll"
    }

    trackpoint {
        // off
        // natural-scroll
        // accel-speed 0.2
        // accel-profile "flat"
        // scroll-method "on-button-down"
        // scroll-button 273
        // scroll-button-lock
        // middle-emulation
    }

    // Uncomment this to make the mouse warp to the center of newly focused windows.
    // warp-mouse-to-focus

    // Focus windows and outputs automatically when moving the mouse into them.
    // Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
    focus-follows-mouse max-scroll-amount="0%"
}

// You can configure outputs by their name, which you can find
// by running `niri msg outputs` while inside a niri instance.
// The built-in laptop monitor is usually called "eDP-1".
// Find more information on the wiki:
// https://yalter.github.io/niri/Configuration:-Outputs
// Remember to uncomment the node by removing "/-"!
output "eDP-1" {
    // Uncomment this line to disable this output.
    // off

    // Resolution and, optionally, refresh rate of the output.
    // The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
    // If the refresh rate is omitted, niri will pick the highest refresh rate
    // for the resolution.
    // If the mode is omitted altogether or is invalid, niri will pick one automatically.
    // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
    //mode "1920x1080@120.030"

    // You can use integer or fractional scale, for example use 1.5 for 150% scale.
    //scale 2

    // Transform allows to rotate the output counter-clockwise, valid values are:
    // normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
    //transform "normal"

    // Position of the output in the global coordinate space.
    // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
    // The cursor can only move between directly adjacent outputs.
    // Output scale and rotation has to be taken into account for positioning:
    // outputs are sized in logical, or scaled, pixels.
    // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
    // so to put another output directly adjacent to it on the right, set its x to 1920.
    // If the position is unset or results in an overlap, the output is instead placed
    // automatically.
    //position x=1280 y=0
    backdrop-color "#000"
}

// Settings that influence how windows are positioned and sized.
// Find more information on the wiki:
// https://yalter.github.io/niri/Configuration:-Layout
layout {
    // Set gaps around windows in logical pixels.
    gaps 8

    // When to center a column when changing focus, options are:
    // - "never", default behavior, focusing an off-screen column will keep at the left
    //   or right edge of the screen.
    // - "always", the focused column will always be centered.
    // - "on-overflow", focusing a column will center it if it doesn't fit
    //   together with the previously focused column.
    center-focused-column "never"

    // You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
    preset-column-widths {
        // Proportion sets the width as a fraction of the output width, taking gaps into account.
        // For example, you can perfectly fit four windows sized "proportion 0.25" on an output.
        // The default preset widths are 1/3, 1/2 and 2/3 of the output.
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 0.9

        // Fixed sets the width in logical pixels exactly.
        // fixed 1920
    }

    // You can also customize the heights that "switch-preset-window-height" (Mod+Shift+R) toggles between.
    // preset-window-heights { }

    // You can change the default width of the new windows.
    default-column-width { proportion 0.5; }
    // If you leave the brackets empty, the windows themselves will decide their initial width.
    // default-column-width {}

    // By default focus ring and border are rendered as a solid background rectangle
    // behind windows. That is, they will show up through semitransparent windows.
    // This is because windows using client-side decorations can have an arbitrary shape.
    //
    // If you don't like that, you should uncomment `prefer-no-csd` below.
    // Niri will draw focus ring and border *around* windows that agree to omit their
    // client-side decorations.
    //
    // Alternatively, you can override it with a window rule called
    // `draw-border-with-background`.

    // You can change how the focus ring looks.
    focus-ring {
        // Uncomment this line to disable the focus ring.
        // off

        // How many logical pixels the ring extends out from the windows.
        width 2

        // Colors can be set in a variety of ways:
        // - CSS named colors: "red"
        // - RGB hex: "#rgb", "#rgba", "#rrggbb", "#rrggbbaa"
        // - CSS-like notation: "rgb(255, 127, 0)", rgba(), hsl() and a few others.

        // Color of the ring on the active monitor.
        active-color "#5f8787"

        // Color of the ring on inactive monitors.
        //
        // The focus ring only draws around the active window, so the only place
        // where you can see its inactive-color is on other monitors.
        inactive-color "#505050"

        // You can also use gradients. They take precedence over solid colors.
        // Gradients are rendered the same as CSS linear-gradient(angle, from, to).
        // The angle is the same as in linear-gradient, and is optional,
        // defaulting to 180 (top-to-bottom gradient).
        // You can use any CSS linear-gradient tool on the web to set these up.
        // Changing the color space is also supported, check the wiki for more info.
        //
        // active-gradient from="#80c8ff" to="#c7ff7f" angle=45

        // You can also color the gradient relative to the entire view
        // of the workspace, rather than relative to just the window itself.
        // To do that, set relative-to="workspace-view".
        //
        // inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
    }

    // You can also add a border. It's similar to the focus ring, but always visible.
    border {
        // The settings are the same as for the focus ring.
        // If you enable the border, you probably want to disable the focus ring.
        off

        width 4
        active-color "#5f8787"
        inactive-color "#505050"

        // Color of the border around windows that request your attention.
        urgent-color "#9b0000"

        // Gradients can use a few different interpolation color spaces.
        // For example, this is a pastel rainbow gradient via in="oklch longer hue".
        //
        // active-gradient from="#e5989b" to="#ffb4a2" angle=45 relative-to="workspace-view" in="oklch longer hue"

        // inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
    }

    // You can enable drop shadows for windows.
    shadow {
        // Uncomment the next line to enable shadows.
        // on

        // By default, the shadow draws only around its window, and not behind it.
        // Uncomment this setting to make the shadow draw behind its window.
        //
        // Note that niri has no way of knowing about the CSD window corner
        // radius. It has to assume that windows have square corners, leading to
        // shadow artifacts inside the CSD rounded corners. This setting fixes
        // those artifacts.
        //
        // However, instead you may want to set prefer-no-csd and/or
        // geometry-corner-radius. Then, niri will know the corner radius and
        // draw the shadow correctly, without having to draw it behind the
        // window. These will also remove client-side shadows if the window
        // draws any.
        //
        // draw-behind-window true

        // You can change how shadows look. The values below are in logical
        // pixels and match the CSS box-shadow properties.

        // Softness controls the shadow blur radius.
        softness 30

        // Spread expands the shadow.
        spread 5

        // Offset moves the shadow relative to the window.
        offset x=0 y=5

        // You can also change the shadow color and opacity.
        color "#0007"
    }

    // Struts shrink the area occupied by windows, similarly to layer-shell panels.
    // You can think of them as a kind of outer gaps. They are set in logical pixels.
    // Left and right struts will cause the next window to the side to always be visible.
    // Top and bottom struts will simply add outer gaps in addition to the area occupied by
    // layer-shell panels and regular gaps.
    struts {
        // left 64
        // right 64
        // top 64
        // bottom 64
    }
}

// Add lines like this to spawn processes at startup.
// Note that running niri as a session supports xdg-desktop-autostart,
// which may be more convenient to use.
// See the binds section below for more spawn examples.

// This line starts waybar, a commonly used bar for Wayland compositors.
spawn-at-startup "waybar"
// spawn-sh-at-startup "swaybg -i ~/.config/wallpapers/bg.png --mode fill"
spawn-sh-at-startup "swaybg -i $(fd -t f . $HOME/.config/wallpapers | shuf -n 1) --mode fill"
spawn-sh-at-startup "swayidle -w"

// To run a shell command (with variables, pipes, etc.), use spawn-sh-at-startup:
// spawn-sh-at-startup "qs -c ~/source/qs/MyAwesomeShell"

hotkey-overlay {
    // Uncomment this line to disable the "Important Hotkeys" pop-up at startup.
    // skip-at-startup
}

// Uncomment this line to ask the clients to omit their client-side decorations if possible.
// If the client will specifically ask for CSD, the request will be honored.
// Additionally, clients will be informed that they are tiled, removing some client-side rounded corners.
// This option will also fix border/focus ring drawing behind some semitransparent windows.
// After enabling or disabling this, you need to restart the apps for this to take effect.
prefer-no-csd

// You can change the path where screenshots are saved.
// A ~ at the front will be expanded to the home directory.
// The path is formatted with strftime(3) to give you the screenshot date and time.
screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

// You can also set this to null to disable saving screenshots to disk.
// screenshot-path null

// Animation settings.
// The wiki explains how to configure individual animations:
// https://yalter.github.io/niri/Configuration:-Animations
animations {
    // Uncomment to turn off all animations.
    // off

    // Slow down all animations by this factor. Values below 1 speed them up instead.
    // slowdown 3.0
}

// Window rules let you adjust behavior for individual windows.
// Find more information on the wiki:
// https://yalter.github.io/niri/Configuration:-Window-Rules

// Work around WezTerm's initial configure bug
// by setting an empty default-column-width.
window-rule {
    // This regular expression is intentionally made as specific as possible,
    // since this is the default config, and we want no false positives.
    // You can get away with just app-id="wezterm" if you want.
    match app-id=r#"^org\.wezfurlong\.wezterm$"#
    default-column-width {}
}

// Open the Firefox picture-in-picture player as floating by default.
window-rule {
    // This app-id regular expression will work for both:
    // - host Firefox (app-id is "firefox")
    // - Flatpak Firefox (app-id is "org.mozilla.firefox")
    match app-id=r#"firefox$"# title="^Picture-in-Picture$"
    open-floating true
}

// Example: block out two password managers from screen capture.
// (This example rule is commented out with a "/-" in front.)
/-window-rule {
    match app-id=r#"^org\.keepassxc\.KeePassXC$"#
    match app-id=r#"^org\.gnome\.World\.Secrets$"#

    block-out-from "screen-capture"

    // Use this instead if you want them visible on third-party screenshot tools.
    // block-out-from "screencast"
}

// Example: enable rounded corners for all windows.
// (This example rule is commented out with a "/-" in front.)
window-rule {
    geometry-corner-radius 12
    clip-to-geometry true
}

binds {
      // Keyboard layout switching (US ⟷ US-intl for MacBook)
      Mod+Slash hotkey-overlay-title="Switch keyboard layout" { switch-layout "next"; }
      // Mod = Super (Windows key)

      // ========================================
      // APPLICATIONS
      // ========================================
      Mod+Return hotkey-overlay-title="Open terminal: alacritty" { spawn "${term}"; }
      Mod+Shift+Return hotkey-overlay-title="Run launcher: rofi" { spawn "rofi" "-show" "drun" "-show-icons"; }
      Mod+D { spawn "${menu}"; }
      Mod+B { spawn "${browser}"; }
      Mod+E hotkey-overlay-title="Open emacs" { spawn "emacsclient" "-c" "-a" "emacs"; }
      Mod+W hotkey-overlay-title="Open browser: brave" { spawn "brave"; }
      Mod+Alt+Minus hotkey-overlay-title="Lock screen: swaylock" { spawn "swaylock"; }
      
      // Launcher and utilities (Fuzzel + Mako replacements for DMS)
      Mod+Space hotkey-overlay-title="App launcher: fuzzel" { spawn "fuzzel"; }
      Mod+N hotkey-overlay-title="Clear notifications" { spawn "makoctl" "dismiss" "-a"; }
      Mod+V hotkey-overlay-title="Clipboard manager" { spawn "sh" "-c" "cliphist list | fuzzel -d | cliphist decode | wl-copy"; }
      
      // ========================================
      // SESSION / COMPOSITOR
      // ========================================
      Mod+Shift+Q hotkey-overlay-title="Quit out of niri" { quit; }
      Mod+Shift+E { quit; }
      Ctrl+Alt+P { power-off-monitors; }
      Mod+Shift+P { power-off-monitors; }
      Mod+Shift+Ctrl+T { toggle-debug-tint; }
      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

      // ========================================
      // SCREENSHOTS
      // ========================================
      // Native Print key (if available)
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }
      Mod+apostrophe { screenshot-screen; }
      Mod+Alt+apostrophe { screenshot-window; }
      Mod+Shift+apostrophe { screenshot; }
      
      // Screenshot with tools (Print key)
      Mod+Print { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }
      Mod+Shift+Print { spawn "sh" "-c" "grim - | swappy -f -"; }
      
      // Alternative shortcuts for compact keyboards (no Print key)
      Mod+S hotkey-overlay-title="Screenshot area (native)" { screenshot; }
      Mod+Shift+S hotkey-overlay-title="Screenshot full screen (native)" { screenshot-screen; }
      Mod+Alt+S hotkey-overlay-title="Screenshot window" { screenshot-window; }
      Mod+Ctrl+S hotkey-overlay-title="Screenshot area with swappy" { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }

      // ========================================
      // OVERVIEW
      // ========================================
      Mod+O repeat=false hotkey-overlay-title="Toggle overview" { toggle-overview; }

      // ========================================
      // WINDOW FOCUS (VIM-STYLE)
      // ========================================
      Mod+H hotkey-overlay-title="Focus column left" { focus-column-left; }
      Mod+J hotkey-overlay-title="Focus window/workspace down" { focus-window-or-workspace-down; }
      Mod+K hotkey-overlay-title="Focus window/workspace up" { focus-window-or-workspace-up; }
      Mod+L hotkey-overlay-title="Focus column right" { focus-column-right; }

      Mod+Left { focus-column-left; }
      Mod+Down { focus-window-or-workspace-down; }
      Mod+Up { focus-window-or-workspace-up; }
      Mod+Right { focus-column-right; }

      // Focus first/last column
      Mod+Home { focus-column-first; }
      Mod+End { focus-column-last; }

      // ========================================
      // WINDOW MOVEMENT
      // ========================================
      Mod+Shift+H { move-column-left-or-to-monitor-left; }
      Mod+Shift+J { move-column-to-workspace-down; }
      Mod+Shift+K { move-column-to-workspace-up; }
      Mod+Shift+L { move-column-right-or-to-monitor-right; }

      Mod+Shift+Left { move-column-left-or-to-monitor-left; }
      Mod+Shift+Down { move-window-down; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Right { move-column-right-or-to-monitor-right; }

      // Move to First/Last
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End { move-column-to-last; }

      // Move workspace itself
      Mod+Ctrl+U { move-workspace-down; }
      Mod+Ctrl+I { move-workspace-up; }

      // ========================================
      // WINDOW SIZING
      // ========================================
      Mod+R { switch-preset-column-width; }
      Mod+Shift+R { switch-preset-window-height; }
      Mod+Ctrl+R { reset-window-height; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+C { center-column; }
      Mod+Ctrl+C { center-visible-columns; }
      Mod+Ctrl+F { expand-column-to-available-width; }

      // Fine-grained sizing
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      // ========================================
      // WORKSPACES
      // ========================================
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      // Move windows to workspaces
      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Ctrl+6 { move-column-to-workspace 6; }
      Mod+Ctrl+7 { move-column-to-workspace 7; }
      Mod+Ctrl+8 { move-column-to-workspace 8; }
      Mod+Ctrl+9 { move-column-to-workspace 9; }

      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }
      Mod+Shift+6 { move-column-to-workspace 6; }
      Mod+Shift+7 { move-column-to-workspace 7; }
      Mod+Shift+8 { move-column-to-workspace 8; }
      Mod+Shift+9 { move-column-to-workspace 9; }

      // Workspace navigation
      Mod+Tab { focus-workspace-down; }
      Mod+Shift+Tab { focus-workspace-up; }
      Mod+Ctrl+H { focus-workspace-down; }
      Mod+Ctrl+L { focus-workspace-up; }
      Mod+Ctrl+Left { focus-workspace-down; }
      Mod+Ctrl+Right { focus-workspace-up; }

      // Mouse wheel workspace navigation
      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }

      // Mouse wheel column navigation
      Mod+WheelScrollRight { focus-column-right; }
      Mod+WheelScrollLeft { focus-column-left; }
      Mod+Ctrl+WheelScrollRight { move-column-right; }
      Mod+Ctrl+WheelScrollLeft { move-column-left; }

      // Shift+Scroll for horizontal navigation
      Mod+Shift+WheelScrollDown { focus-column-right; }
      Mod+Shift+WheelScrollUp { focus-column-left; }
      Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
      Mod+Ctrl+Shift+WheelScrollUp { move-column-left; }

      // Monitor focus
      Mod+Ctrl+Comma { focus-monitor-previous; }
      Mod+Ctrl+Period { focus-monitor-next; }

      // Move to monitors
      Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

      // ========================================
      // WINDOW MANAGEMENT
      // ========================================
      Mod+Q { close-window; }
      Mod+Shift+C repeat=false hotkey-overlay-title="Close window" { close-window; }
      
      // Floating windows
      Mod+Alt+V { toggle-window-floating; }
      Mod+Shift+V { switch-focus-between-floating-and-tiling; }
      Mod+Shift+Space { toggle-window-floating; }
      
      // Tabbed display
      Mod+T hotkey-overlay-title="Toggle tabbed display" { toggle-column-tabbed-display; }
      
      // Consume or expel window into/from column
      Mod+BracketLeft { consume-window-into-column; }
      Mod+BracketRight { expel-window-from-column; }
      Mod+Alt+H { consume-or-expel-window-left; }
      Mod+Alt+L { consume-or-expel-window-right; }

      // ========================================
      // MEDIA KEYS
      // ========================================
      XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
      XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
      XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

      XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

      XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
      XF86AudioStop allow-when-locked=true { spawn-sh "playerctl stop"; }
      XF86AudioPause allow-when-locked=true { spawn-sh "playerctl play-pause"; }
      XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }
      XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }

      // ========================================
      // SPECIAL
      // ========================================
      Mod+Shift+Slash hotkey-overlay-title="Show important bindings" { show-hotkey-overlay; }

}
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.kdl".text = mainConfigKdl;
}
