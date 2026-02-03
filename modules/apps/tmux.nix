# modules/apps/tmux.nix
#
# ████████╗███╗   ███╗██╗   ██╗██╗  ██╗
# ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝
#    ██║   ██╔████╔██║██║   ██║ ╚███╔╝
#    ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗
#    ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
#    ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
#
# Terminal multiplexer - DevOps optimized configuration
# Supports: Rust, Go, Lua, Python, Node.js, Docker, K8s
# https://github.com/tmux/tmux

{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.tmux.enable {
    ############################################
    # Tmux Dependencies
    ############################################
    home.packages = with pkgs; [

      fd # Fast find alternative
      zoxide # Smart directory jumper
      jq # JSON processor
      yq-go # YAML processor
      fzf # Fuzzy finder
    ];

    ############################################
    # Tmux via Home Manager
    ############################################
    programs.tmux = {
      enable = true;

      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";
      historyLimit = 1000000;
      baseIndex = 1;

      # Key bindings
      prefix = "C-a";
      keyMode = "vi";
      mouse = true;
      escapeTime = 0;
      
      # Behavior settings
      extraConfig = ''
#####################################################
# CORE / TERMINAL
#####################################################
#set -g default-terminal "tmux-256color"
#set -as terminal-features ",xterm-256color:RGB"
        # Colors - optimized for development
        set-option -g default-terminal "screen-256color"
        set-option -g terminal-overrides ",xterm-256color:RGB"
        set-option -ga terminal-overrides ",*256col*:Tc"
set -g focus-events on

#####################################################
# PREFIX / RELOAD
#####################################################
unbind C-b
set -g prefix C-a
bind C-a send-prefix

bind r source-file ~/.config/tmux/tmux.conf \; display-message "󰑓 Tmux Config Reloaded"

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
set -g default-shell /bin/zsh
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

    #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # ⌨️  KEY BINDINGS - DevOps Optimized
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        # Prefix bindings
        bind C-a send-prefix             # Send prefix to nested tmux
        bind C-x lock-server
        #bind c new-window -c "#{pane_current_path}"
        bind C-c new-window -c "''$HOME"
        bind C-d detach
        bind * list-clients
        
        # Window navigation
        bind H previous-window
        bind L next-window
        bind C-a last-window
        bind C-w list-windows
        bind w list-windows
        bind Tab last-window
        
        # Window management
        bind r command-prompt -I "#W" "rename-window '%%'"
        bind R source-file ''$HOME/.config/tmux/tmux.conf \; display "󰑓 Tmux Config Reloaded"
        bind c new-window -c "#{pane_current_path}"
        bind C kill-window
        bind '"' choose-window
        
        # Pane splitting - intuitive keys
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        
        # Pane navigation - vim style
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        
        # Pane resizing - repeatable
        bind -r , resize-pane -L 10
        bind -r . resize-pane -R 10
        bind -r - resize-pane -D 5
        bind -r = resize-pane -U 5
        bind -r < resize-pane -L 20
        bind -r > resize-pane -R 20
        bind -r _ resize-pane -D 10
        bind -r + resize-pane -U 10
        
        # Pane management
        bind z resize-pane -Z            # Toggle zoom
        bind x kill-pane                 # Kill pane without confirmation
        bind X swap-pane -D              # Swap with next pane
        bind B break-pane                # Break pane to new window
        bind J join-pane -t :1           # Join pane to window 1
        
        # Session management
        bind S choose-session
        bind Q kill-session
        bind D detach-client
        
        # Utilities
        bind : command-prompt
        bind ? list-keys
        bind P set pane-border-status    # Toggle pane borders
        bind * setw synchronize-panes    # Sync panes
        bind K send-keys "clear" C-m     # Clear terminal
        bind e send-keys "tmux capture-pane -p -S - | nvim -c 'set buftype=nofile' +" Enter
        
        # Copy mode - vi bindings
        bind Escape copy-mode
        bind p paste-buffer
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind -T copy-mode-vi Escape send-keys -X cancel
        
        # Copy mode navigation
        bind-key -T copy-mode-vi C-h select-pane -L
        bind-key -T copy-mode-vi C-j select-pane -D
        bind-key -T copy-mode-vi C-k select-pane -U
        bind-key -T copy-mode-vi C-l select-pane -R

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

# Vim <-> tmux navigation
set -g @plugin 'joshmedeski/vim-tmux-navigator'

# Clipboard
set -g @plugin 'tmux-plugins/tmux-yank'

# Theme
set -g @plugin 'janoamaral/tokyo-night-tmux'

  #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # 🚀 DEVOPS SHORTCUTS
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        # Git operations
        bind g new-window -S -n "🌳 git" "lazygit"
        bind G new-window -n "😺 gh" "gh-dash"
        
        # Language-specific dev environments
        bind M-r new-window -c "#{pane_current_path}" -n "🦀 rust" "echo 'Rust Dev Environment' && exec $SHELL"
        bind M-g new-window -c "#{pane_current_path}" -n "🐹 go" "echo 'Go Dev Environment' && exec $SHELL"
        bind M-l new-window -c "#{pane_current_path}" -n "🌙 lua" "echo 'Lua Dev Environment' && exec $SHELL"
        bind M-p new-window -c "#{pane_current_path}" -n "🐍 python" "echo 'Python Dev Environment' && exec $SHELL"
        bind M-n new-window -c "#{pane_current_path}" -n "📦 node" "echo 'Node.js Dev Environment' && exec $SHELL"
        
        # Container & orchestration
        bind M-d new-window -n "🐳 docker" "docker ps && exec $SHELL"
        bind M-k new-window -n "☸️  k8s" "kubectl get pods && exec $SHELL"
        
        # Editor & tools
        bind E new-window -S -n "📝 editor" "nvim +GoToFile"
        bind M-h new-window -n "✨ helix" "hx"
        bind M-t new-window -n "📊 htop" "htop"
        bind M-f new-window -n "📁 yazi" "yazi"
        

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
  "run 'git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && ~/.config/tmux/plugins/tpm/bin/install_plugins'"

run "$HOME/.config/tmux/plugins/tpm/tpm"


      '';
    };


    #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 📦 TPM (Tmux Plugin Manager) SETUP
    #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    # Install TPM if not already installed
    home.activation.installTPM = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
        echo "✓ TPM installed. Run 'prefix + I' in tmux to install plugins."
      fi
    '';
  };
}
