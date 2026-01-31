# modules/apps/tmux.nix
#
# ████████╗███╗   ███╗██╗   ██╗██╗  ██╗
# ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝
#    ██║   ██╔████╔██║██║   ██║ ╚███╔╝
#    ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗
#    ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
#    ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
#
# Terminal multiplexer
# https://github.com/tmux/tmux

{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.tmux.enable {
    ############################################
    # Tmux Dependencies
    ############################################
    home.packages = with pkgs; [
      sesh       # Smart session manager for tmux
      gitmux     # Show git status in tmux status line
      tmuxifier  # Tmux project/session manager
      fd         # Fast find alternative (used by sesh)
      zoxide     # Smart directory jumper (used by sesh)
    ];

    ############################################
    # Tmux via Home Manager
    ############################################
    programs.tmux = {
      enable = true;
      
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "xterm-256color";
      historyLimit = 1000000;
      baseIndex = 1;
      
      # Key bindings
      prefix = "C-a";
      keyMode = "vi";
      mouse = true;
      
      # Plugins
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        # Note: fzf-url, nerd-font-window-name, sessionx, floax, notify need to be added via TPM
      ];
      
      extraConfig = ''
        #
        # ████████╗███╗   ███╗██╗   ██╗██╗  ██╗
        # ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝
        #    ██║   ██╔████╔██║██║   ██║ ╚███╔╝
        #    ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗
        #    ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
        #    ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
        #
        # Terminal multiplexer
        # https://github.com/tmux/tmux

        # global sessions
        # bind-key "K" display-popup -h 90% -w 50% -E "sesh ui"
        bind-key "K" run-shell "sesh connect \"$(
          sesh list --icons --hide-duplicates | fzf-tmux -p 100%,100% --no-border \
            --list-border \
            --no-sort --prompt '⚡  ' \
            --input-border \
            --header-border \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-b:abort' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:70%' \
            --preview 'sesh preview {}' \
        )\""

        bind-key "N" display-popup -E "sesh ui"

        # root sessions
        bind-key "R" run-shell "sesh connect \"\$(
          sesh list --icons | fzf-tmux -p 100%,100% --no-border \
            --query  \"\$(sesh root)\" \
            --list-border \
            --no-sort --prompt '⚡  ' \
            --input-border \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-b:abort' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:70%' \
            --preview 'sesh preview {}' \
        )\""

        # TODO: learn how this works
        set-option -g focus-events on

        # TODO: find a way to toggle this?
        set-option -g display-time 3000

        # colors
        set -g default-terminal "xterm-256color"
        set -ga terminal-overrides ",*256col*:Tc"

        set -g base-index 1          # start indexing windows at 1 instead of 0
        set -g detach-on-destroy off # don't exit from tmux when closing a session
        set -g escape-time 0         # zero-out escape time delay
        set -g history-limit 1000000 # increase history size (from 2,000)
        set -g mouse on              # enable mouse support
        set -g renumber-windows on   # renumber all windows when any window is closed
        set -g set-clipboard on      # use system clipboard

        # ascii color definitions
        # 0  black
        # 1  red
        # 2  green
        # 3  yellow
        # 4  blue
        # 5  magenta
        # 6  cyan
        # 7  white
        # 8  bright black
        # 9  bright red
        # 10 bright green
        # 11 bright yellow
        # 12 bright blue
        # 13 bright magenta
        # 14 bright cyan
        # 15 bright white
        # -1 default

        # status bar
        set -g status-interval 3
        set -g status-justify absolute-centre
        set -g status-left " #[fg=blue,bold]#S #[fg=white,nobold]#(gitmux -cfg $HOME/.config/tmux/gitmux.yml) "
        set -g status-left-length 300    # increase length (from 10)
        set -g status-position top       # macOS / darwin style
        set -g status-right ""
        set -g status-style 'bg=default' # transparent

        # windows
        set -g window-status-current-format '#[fg=magenta]*#W'
        set -g window-status-format ' #[fg=gray]#W'

        # panes
        set -g pane-active-border-style 'fg=black,bg=default'
        set -g pane-border-style 'fg=brightblack,bg=default'

        set -g allow-passthrough on
        set -g message-command-style bg=default,fg=yellow
        set -g message-style bg=default,fg=yellow
        set -g mode-style bg=default,fg=yellow

        # bindings
        bind -N "⌘+9 switch to root session (via sesh) " 9 run-shell "sesh connect --root $(pwd)"
        bind -N "⌘+^+t join pane" J join-pane -t 1
        bind -N "⌘+a ai" A new-window -S -n '🤖' 'ai'
        bind -N "⌘+b builder" b new-window -S -n '🔨' 'build'
        bind -N "⌘+d dev" D new-window -S -n '🔧' 'dev'
        bind -N "⌘+e editor" E new-window -S -n '📝' 'nvim +GoToFile'
        bind -N "⌘+⇧+G gh-dash " G new-window -c "#{pane_current_path}" -n "😺" "ghd 2> /dev/null"
        bind -N "⌘+g lazygit" g new-window -S -n '🌳' 'lazygit'
        # bind -N "⌘+G git commit (raycast) " G new-window -c "#{pane_current_path}" -n "🔒" "raycast-git-commit.sh"
        bind -N "⌘+l last-session (via sesh) " L run-shell "sesh last || tmux display-message -d 1000 'Only one session'"
        bind -N "⌘+⇧+Q kill current session" Q kill-session
        bind -N "⌘+⇧+R run a script" Y split-window -v -l 10 "npm run (jq -r '.scripts | keys[]' package.json | fzf --no-border)"
        bind -N "⌘+⇧+T break pane" B break-pane

        bind '%' split-window -c '#{pane_current_path}' -h
        bind '"' split-window -c '#{pane_current_path}'
        bind c new-window -c '#{pane_current_path}'

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
        bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt (cmd+w)
        bind-key e send-keys "tmux capture-pane -p -S - | nvim -c 'set buftype=nofile' +" Enter

        # NOTE: can be used for debugging
        # )\" 2> /tmp/sesh-$(date +"%Y-%m-%d-%H-%M-%S").txt"

        bind-key "Z" display-popup -E "sesh connect \$(sesh list | zf --height 24)"

        # plugin settings
        set -g @floax-bind H
        set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
        set -g @fzf-url-history-limit '2000'
        set -g @thumbs-command 'echo -n {} | pbcopy' # copy to clipboard
        set -g @thumbs-key C
        set -g @tmux-last-color on
        set -g @tmux-last-pager 'less -r'
        set -g @tmux-last-pager 'less'
        set -g @tmux-last-prompt-pattern ' '
        set -g @tmux-nerd-font-window-name-shell-icon ""
        set -g @tmux-nerd-font-window-name-show-name false
        set -g @tnotify-custom-cmd 'bash ~/c/dotfiles/bin/tmux-notify.sh'

        # plugins

        # TODO: revisit using this?
        # set -g @plugin 'git@github.com:joshmedeski/tmux-overmind'
        # set -g @plugin 'IdoKendo/tmux-lazy'
        # set -g @plugin 'git@github.com:joshmedeski/tmux-voice-mode'
        # set -g @plugin 'fcsonline/tmux-thumbs'          # <cmd|shift>+c
        # set -g @plugin 'jimeh/tmuxifier'
        # set -g @plugin 'tmux-plugins/tmux-resurrect'

        set -g @plugin 'git@github.com:joshmedeski/tmux-fzf-url'
        set -g @plugin 'git@github.com:joshmedeski/tmux-nerd-font-window-name'
        set -g @plugin 'joshmedeski/vim-tmux-navigator' # <ctrl>+hjkl
        set -g @plugin 'rickstaa/tmux-notify'
        set -g @plugin 'omerxx/tmux-sessionx'
        set -g @plugin 'omerxx/tmux-floax'

        # set-option -g automatic-rename-format '#(~/git_apps/tmux-nerd-font-window-name/bin/tmux-nerd-font-window-name #{pane_current_command} #{window_panes}) #{b:pane_current_path}'

        set -g @plugin 'tmux-plugins/tpm'        # load tpm
        run "$HOME/.config/tmux/plugins/tpm/tpm" # run tpm (always end of file)

        # TODO: create a fabric workflow (with tmux popop)
        # bind-key "A" display-popup -E -w 40% "sesh connect \"$(
        #   fabric -l | gum filter --limit 1 --fuzzy --no-sort --placeholder 'Pick a fabric pattern' --prompt='🧠'
        # )\""

        # NOTE: hide duplicates flag
        # sesh list --icons --hide-duplicates | fzf-tmux -p 100%,100% --no-border \
      '';
    };

    # Create gitmux config file
    home.file.".config/tmux/gitmux.yml".text = ''
      #
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
          clean: ""
          branch: ""
          hashprefix: ":"
          staged: " "
          conflict: "󰕚 "
          untracked: "󱀶 "
          modified: " "
          stashed: " "
          insertions: " "
          deletions: " "
        styles:
          state: "#[fg=red,nobold]"
          branch: "#[fg=white,italics]"
          staged: "#[fg=green,nobold]"
          conflict: "#[fg=red,nobold]"
          modified: "#[fg=yellow,nobold]"
          untracked: "#[fg=magenta,nobold]"
          stashed: "#[fg=gray,nobold]"
          clean: "#[fg=green,nobold]"
          divergence: "#[fg=cyan,nobold]"
        layout: [branch, divergence, flags, stats]
        options:
          branch_max_len: 0
          hide_clean: false
    '';
  };
}