# modules/apps/kitty.nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
  ];

  # System-wide, Nix-managed kitty config
  environment.etc."xdg/kitty/kitty.conf".text = ''
    # ===== Font =====
    font_family      JetBrainsMono Nerd Font
    bold_font        auto
    italic_font      auto
    bold_italic_font auto
    font_size        11.0

    # ===== Transparency =====
    # 1.0 = fully opaque, 0.0 = fully transparent
    background_opacity 0.90
    dynamic_background_opacity yes

    # ===== Behavior / UX =====
    enable_audio_bell no
    confirm_os_window_close 0
    scrollback_lines 20000
    wheel_scroll_multiplier 3.0
    copy_on_select yes
    cursor_shape beam
    cursor_blink_interval 0

    # ===== Catppuccin Mocha =====
    foreground              #cdd6f4
    background              #1e1e2e
    selection_foreground    #1e1e2e
    selection_background    #f5c2e7

    cursor                  #f5e0dc
    cursor_text_color       #1e1e2e

    url_color               #89b4fa

    active_border_color     #cba6f7
    inactive_border_color   #45475a

    # normal
    color0  #45475a
    color1  #f38ba8
    color2  #a6e3a1
    color3  #f9e2af
    color4  #89b4fa
    color5  #f5c2e7
    color6  #94e2d5
    color7  #bac2de

    # bright
    color8  #585b70
    color9  #f38ba8
    color10 #a6e3a1
    color11 #f9e2af
    color12 #89b4fa
    color13 #f5c2e7
    color14 #94e2d5
    color15 #cdd6f4
  '';

  # Optional: create a symlink in ~/.config so apps that only check ~/.config behave
  systemd.user.services."xdg-kitty-config-link" = {
    description = "Symlink Kitty config from /etc/xdg to ~/.config";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail
      mkdir -p "$HOME/.config/kitty"
      [ -e "$HOME/.config/kitty/kitty.conf" ] || ln -s /etc/xdg/kitty/kitty.conf "$HOME/.config/kitty/kitty.conf"
    '';
  };
}