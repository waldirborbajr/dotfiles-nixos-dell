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
      sesh # Smart session manager for tmux
      gitmux # Show git status in tmux status line
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
        # Unbind default prefix
        unbind C-b

      # Behavior settings
      extraConfig = ''
        # Unbind default prefix
        unbind C-b
        
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # 🎯 CORE SETTINGS
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        set -g prefix C-a
        set -g base-index 1              # start indexing windows at 1 instead of 0
        set -g detach-on-destroy off     # don't exit from tmux when closing a session
        set -g escape-time 0             # zero-out escape time delay
        set -g history-limit 1000000     # increase history size (from 2,000)
        set -g renumber-windows on       # renumber all windows when any window is closed
        set -g set-clipboard on          # use system clipboard
        set -g status-position top       # macOS / darwin style
        set -g focus-events on           # enable focus events
        setw -g mode-keys vi             # vi mode in copy mode
        setw -g pane-base-index 1        # start pane indexing at 1
        
        # Colors - optimized for development
        set-option -g default-terminal "screen-256color"
        set-option -g terminal-overrides ",xterm-256color:RGB"
        set-option -ga terminal-overrides ",*256col*:Tc"
        
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # 🎨 THEME & STATUS BAR
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        # Pane borders
        set -g pane-active-border-style "fg=magenta,bg=default"
        set -g pane-border-style "fg=brightblack,bg=default"
        
        # Status bar
        set -g status-interval 3
        set -g status-justify centre
        set -g status-style "bg=default,fg=white"
        set -g status-left-length 100
        set -g status-right-length 100
        set -g status-left " #[fg=blue,bold]#S #[fg=white,nobold]#(gitmux -cfg $HOME/.config/tmux/gitmux.yml) "
        set -g status-right "#[fg=gray]%H:%M "
        
        # Window status
        set -g window-status-current-format "#[fg=magenta,bold]#{?window_zoomed_flag,🔍 ,}#I:#W"
        set -g window-status-format "#[fg=gray]#I:#W"
        
        # Message style
        set -g message-style "bg=default,fg=yellow,bold"
        set -g message-command-style "bg=default,fg=yellow"
        set -g mode-style "bg=yellow,fg=black"
        
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # ⌨️  KEY BINDINGS - DevOps Optimized
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        # Prefix bindings
        bind C-a send-prefix             # Send prefix to nested tmux
        bind C-x lock-server
        bind C-c new-window -c "$HOME"
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
        bind R source-file $HOME/.config/tmux/tmux.conf \; display "Config reloaded!"
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
        
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # 🚀 DEVOPS SHORTCUTS
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        # Git operations
        bind g new-window -S -n "🌳 git" "lazygit"
        bind G new-window -n "😺 gh" "gh dash"
        
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
        
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # 🔍 SESSION MANAGEMENT WITH SESH
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        # Fuzzy session switcher
        bind K run-shell "sesh connect \"$(
          sesh list --icons --hide-duplicates | fzf-tmux -p 80%,80% \
            --no-sort --border-label ' Sessions ' \
            --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g config ^x zoxide ^f find ^d delete' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . $HOME)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --color "border:magenta,label:blue,prompt:cyan" \
        )\""
        
        # Last session toggle
        bind l run-shell "sesh last"
        
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # 🔌 PLUGINS - TPM (Tmux Plugin Manager)
        #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        set -g @plugin "tmux-plugins/tpm"
        set -g @plugin "tmux-plugins/tmux-sensible"
        set -g @plugin "tmux-plugins/tmux-yank"
        set -g @plugin "tmux-plugins/tmux-resurrect"
        set -g @plugin "tmux-plugins/tmux-continuum"
        set -g @plugin "christoomey/vim-tmux-navigator"
        set -g @plugin "sainnhe/tmux-fzf"
        set -g @plugin "wfxr/tmux-fzf-url"
        
        # Plugin settings
        set -g @continuum-restore "on"
        set -g @resurrect-strategy-nvim "session"
        set -g @resurrect-capture-pane-contents "on"
        set -g @fzf-url-fzf-options "-p 60%,30% --prompt='   ' --border-label=' 🔗 Open URL '"
        set -g @fzf-url-history-limit "2000"
        
        # Initialize TPM (keep this at the bottom)
        run-shell "test -e $HOME/.config/tmux/plugins/tpm/tpm && $HOME/.config/tmux/plugins/tpm/tpm || true"
      '';
    };

    #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 📊 GITMUX CONFIGURATION
    #━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    home.file.".config/tmux/gitmux.yml".text = ''
      #  ██████╗ ██╗████████╗███╗   ███╗██╗   ██╗██╗  ██╗
      # ██╔════╝ ██║╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝
      # ██║  ███╗██║   ██║   ██╔████╔██║██║   ██║ ╚███╔╝
      # ██║   ██║██║   ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗
      # ╚██████╔╝██║   ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
      #  ╚═════╝ ╚═╝   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
      #
      # Git in your tmux status bar
      # https://github.com/arl/gitmux

      tmux:
        symbols:
          ahead: "↑"
          behind: "↓"
          clean: "✓"
          branch: ""
          hashprefix: ":"
          staged: ""
          conflict: "󰕚"
          untracked: "󱀶"
          modified: ""
          stashed: ""
          insertions: ""
          deletions: ""
        styles:
          state: "#[fg=red,nobold]"
          branch: "#[fg=white,italics]"
          staged: "#[fg=green,nobold]"
          conflict: "#[fg=red,nobold]"
          modified: "#[fg=yellow,nobold]"
          untracked: "#[fg=magenta,nobold]"
          stashed: "#[fg=cyan,nobold]"
          clean: "#[fg=green,nobold]"
          divergence: "#[fg=cyan,nobold]"
        layout: [branch, divergence, flags, stats]
        options:
          branch_max_len: 30
          hide_clean: false
    '';

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
