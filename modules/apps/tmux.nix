# modules/apps/tmux.nix
#
# tmux — NixOS managed (no autostart)
# - Config declarativa em /etc/xdg/tmux/tmux.conf
# - Plugins via TPM (auto-bootstrap)
# - Compatível sem Home-Manager

{ config, pkgs, lib, ... }:

{
  ############################################
  # Package
  ############################################
  environment.systemPackages = with pkgs; [
    tmux
    git
  ];

  ############################################
  # tmux config (Nix-managed)
  # Canonical: /etc/xdg/tmux/tmux.conf
  ############################################
  environment.etc."xdg/tmux/tmux.conf".text = ''
    #####################################################
    # CORE / TERMINAL
    #####################################################
    set -g default-terminal "tmux-256color"
    set -as terminal-features ",xterm-256color:RGB"
    set -g focus-events on

    #####################################################
    # PREFIX / RELOAD
    #####################################################
    unbind C-b
    set -g prefix C-a
    bind C-a send-prefix

    bind r source-file ~/.config/tmux/tmux.conf \; display-message "󰑓 tmux reloaded"

    #####################################################
    # INDEXES / WINDOWS
    #####################################################
    set -g base-index 1
    set -g pane-base-index 1
    set -g renumber-windows on

    #####################################################
    # GENERAL BEHAVIOR
    #####################################################
    set -g mouse on
    set -g default-shell ${pkgs.zsh}/bin/zsh
    set -g repeat-time 600
    set -g history-limit 15000
    set -g status-position bottom
    set -g status-interval 5
    set -g display-time 800

    #####################################################
    # SMART WINDOW NAMES (DEVOPS FRIENDLY)
    #####################################################
    setw -g automatic-rename on
    set -g automatic-rename-format '#{pane_current_command}'

    #####################################################
    # PANE NAVIGATION (VIM STYLE)
    #####################################################
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # No-prefix navigation (turbo mode)
    bind -n C-h select-pane -L
    bind -n C-j select-pane -D
    bind -n C-k select-pane -U
    bind -n C-l select-pane -R

    #####################################################
    # RESIZE PANES
    #####################################################
    bind -r Left  resize-pane -L 5
    bind -r Right resize-pane -R 5
    bind -r Up    resize-pane -U 3
    bind -r Down  resize-pane -D 3

    # Vim-style resize
    bind -r H resize-pane -L 5
    bind -r J resize-pane -D 3
    bind -r K resize-pane -U 3
    bind -r L resize-pane -R 5

    #####################################################
    # SPLITS / WINDOWS (PATH AWARE)
    #####################################################
    unbind %
    unbind '"'

    bind | split-window -h -c "#{pane_current_path}"
    bind _ split-window -v -c "#{pane_current_path}"

    bind c new-window -c "#{pane_current_path}"
    bind m resize-pane -Z

    #####################################################
    # WINDOW SWITCHING
    #####################################################
    bind -n S-Left  previous-window
    bind -n S-Right next-window
    bind -n M-H previous-window
    bind -n M-L next-window

    #####################################################
    # COPY MODE (VI)
    #####################################################
    setw -g mode-keys vi

    bind -T copy-mode-vi v     send -X begin-selection
    bind -T copy-mode-vi C-v   send -X rectangle-toggle
    bind -T copy-mode-vi y     send -X copy-selection-and-cancel
    bind -T copy-mode-vi Enter send -X copy-selection-and-cancel

    #####################################################
    # THEME — TOKYO NIGHT
    #####################################################
    set -g @tokyo-night-tmux_show_datetime 0
    set -g @tokyo-night-tmux_show_path 1
    set -g @tokyo-night-tmux_path_format relative
    set -g @tokyo-night-tmux_window_id_style dsquare
    set -g @tokyo-night-tmux_show_git 0

    #####################################################
    # PLUGINS
    #####################################################
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'joshmedeski/vim-tmux-navigator'
    set -g @plugin 'tmux-plugins/tmux-yank'
    set -g @plugin 'janoamaral/tokyo-night-tmux'

    #####################################################
    # SESSION PERSISTENCE (DEVOPS GOLD)
    #####################################################
    set -g @plugin 'tmux-plugins/tmux-resurrect'
    set -g @plugin 'tmux-plugins/tmux-continuum'

    set -g @resurrect-capture-pane-contents 'on'
    set -g @resurrect-strategy-nvim 'session'
    set -g @resurrect-strategy-vim 'session'
    set -g @resurrect-processes 'ssh kubectl helm terraform nvim vim'

    set -g @continuum-restore 'on'
    set -g @continuum-save-interval '10'

    #####################################################
    # TPM BOOTSTRAP (SEMPRE NO FINAL)
    #####################################################
    if "test ! -d ~/.config/tmux/plugins/tpm" \
      "run '${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && ~/.config/tmux/plugins/tpm/bin/install_plugins'"

    run "$HOME/.config/tmux/plugins/tpm/tpm"
  '';

  ############################################
  # Symlink into ~/.config (no Home-Manager)
  ############################################
  systemd.user.services."xdg-config-links-tmux" = {
    description = "Symlink tmux XDG config from /etc/xdg to ~/.config";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      mkdir -p "$HOME/.config/tmux"

      [ -e "$HOME/.config/tmux/tmux.conf" ] || \
        ln -s /etc/xdg/tmux/tmux.conf "$HOME/.config/tmux/tmux.conf"
    '';
  };
}