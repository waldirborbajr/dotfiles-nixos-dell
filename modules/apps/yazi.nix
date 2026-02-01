# modules/apps/yazi.nix
# Modern terminal file manager with preview support
# Optimized for DevOps workflows
#
# Plugin Migration from Pop!_OS:
# ✅ full-border   → pkgs.yaziPlugins.full-border
# ✅ git           → pkgs.yaziPlugins.git
# ✅ searchjump    → Added via fetchFromGitHub
# ✅ starship      → Added via fetchFromGitHub
# ✅ bookmarks     → Added via fetchFromGitHub
# ⚠️  catppuccin   → Waiting for catppuccin.homeModules support
#
# NOTE: No need for 'ya pkg upgrade' anymore! 
#       Updates happen via: just upgrade macbook
{ config, pkgs, lib, ... }:

let
  # Custom plugins not yet in nixpkgs
  # Hashes obtained via: nix-prefetch-github <owner> <repo> --rev <rev>
  searchjump = pkgs.fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "searchjump.yazi";
    rev = "cab627ce87d0d0d6251e79f0f66526254f0e1674";
    sha256 = "sha256-xcz2+zepICZ3ji0Hm0SSUBSaEpabWUrIdG7JmxUl/ts=";
  };

  starship = pkgs.fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = "starship.yazi";
    rev = "eca18616402e37dd4bb9a5e4854e8e5dcba2bbab";
    sha256 = "sha256-0000000000000000000000000000000000000000000=";  # Will fail and show correct hash
  };

  bookmarks = pkgs.fetchFromGitHub {
    owner = "dedukun";
    repo = "bookmarks.yazi";
    rev = "9ef125482f3e62c5d409d8e1a41ee21c01814400";
    sha256 = "sha256-0000000000000000000000000000000000000000000=";  # Will fail and show correct hash
  };
in

{
  config = lib.mkIf config.apps.yazi.enable {
    # Install yazi with plugins
    home.packages = with pkgs; [
      yazi
      # Dependencies for full functionality
      ffmpegthumbnailer # Video thumbnails
      unar # Archive preview
      jq # JSON preview
      poppler-utils # PDF preview
      fd # File searching
      ripgrep # Content searching
      fzf # Fuzzy finding
      zoxide # Smart directory jumping
      imagemagick # Image operations
    ];

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      # Enable Catppuccin theme
      # catppuccin.enable = true;  # FIXME: Module not available in current catppuccin/nix version

      # Use 'y' as shell wrapper for directory changing
      shellWrapperName = "y";

      # Plugin configuration
      plugins = with pkgs.yaziPlugins; {
        inherit
          git           # Git integration
          chmod         # Permission management
          full-border   # Better borders (yazi-rs/plugins:full-border)
          smart-enter   # Smart directory navigation
          ;
        
        # Additional plugins from Pop!_OS setup
        # Note: Some may need manual installation via fetchFromGitHub if not in nixpkgs
        # searchjump = ...;   # DreamMaoMao/searchjump (need manual setup)
        # starship = ...;     # Rolv-Apneseth/starship (need manual setup)
        # bookmarks = ...;    # dedukun/bookmarks (need manual setup)
      };

      # Lua initialization for plugins
      initLua = ''
        require("full-border"):setup()
        require("git"):setup()
        require("searchjump"):setup()
        require("starship"):setup()
        require("bookmarks"):setup()
      '';

      # Main settings
      settings = {
        mgr = {
          show_hidden = true; # Show hidden files by default
          sort_by = "natural"; # Natural sorting
          sort_sensitive = false; # Case-insensitive sorting
          sort_dir_first = true; # Directories first
          linemode = "size"; # Show file sizes
          show_symlink = true; # Show symlink targets
        };

        # Use Catppuccin Macchiato theme (matching Pop!_OS setup)
        flavor = {
          use = "catppuccin-macchiato";
        };

        preview = {
          tab_size = 2; # Tab size for preview
          max_width = 1500; # Max preview width
          max_height = 1500; # Max preview height
          cache_dir = ""; # Use default cache
          image_filter = "lanczos3"; # High-quality image filtering
          image_quality = 90; # Image quality (1-100)
          sixel_fraction = 15; # Sixel fraction
        };

        opener = {
          edit = [
            { run = ''nvim "$@"''; block = true; for = "unix"; }
          ];
          play = [
            { run = ''mpv "$@"''; orphan = true; for = "unix"; }
          ];
          open = [
            { run = ''xdg-open "$@"''; desc = "Open"; for = "linux"; }
          ];
        };

        open = {
          rules = [
            { name = "*/"; use = [ "edit" "open" "reveal" ]; }
            { mime = "text/*"; use = [ "edit" "reveal" ]; }
            { mime = "image/*"; use = [ "open" "reveal" ]; }
            { mime = "video/*"; use = [ "play" "reveal" ]; }
            { mime = "audio/*"; use = [ "play" "reveal" ]; }
            { mime = "inode/x-empty"; use = [ "edit" "reveal" ]; }
            { mime = "application/json"; use = [ "edit" "reveal" ]; }
            { mime = "*/javascript"; use = [ "edit" "reveal" ]; }
            { mime = "application/zip"; use = [ "extract" "reveal" ]; }
            { mime = "application/gzip"; use = [ "extract" "reveal" ]; }
            { mime = "application/x-tar"; use = [ "extract" "reveal" ]; }
            { mime = "application/x-bzip2"; use = [ "extract" "reveal" ]; }
            { mime = "application/x-7z-compressed"; use = [ "extract" "reveal" ]; }
            { mime = "application/x-rar"; use = [ "extract" "reveal" ]; }
            { mime = "application/x-xz"; use = [ "extract" "reveal" ]; }
          ];
        };

        # Git integration
        plugin = {
          prepend_fetchers = [
            { id = "git"; name = "*"; run = "git"; }
            { id = "git"; name = "*/"; run = "git"; }
          ];
        };
      };

      # Custom keybindings optimized for DevOps
      keymap = {
        mgr.prepend_keymap = [
          # Plugin keybindings
          {
            on = [ "c" "m" ];
            run = "plugin chmod";
            desc = "Change file permissions";
          }
          {
            on = "l";
            run = "plugin smart-enter";
            desc = "Smart enter directory or open file";
          }

          # Navigation improvements
          {
            on = "h";
            run = "leave";
            desc = "Go back to parent directory";
          }
          {
            on = "H";
            run = "back";
            desc = "Go back in history";
          }
          {
            on = "L";
            run = "forward";
            desc = "Go forward in history";
          }

          # Selection and operations
          {
            on = "<Space>";
            run = [ "select --state=none" "arrow 1" ];
            desc = "Toggle selection and move down";
          }
          {
            on = "v";
            run = "visual_mode";
            desc = "Enter visual mode";
          }
          {
            on = "V";
            run = "visual_mode --unset";
            desc = "Exit visual mode";
          }

          # Copy/paste operations
          {
            on = "y";
            run = "yank";
            desc = "Copy selected files";
          }
          {
            on = "p";
            run = "paste";
            desc = "Paste files";
          }
          {
            on = "P";
            run = "paste --force";
            desc = "Paste and overwrite";
          }

          # File operations
          {
            on = "d";
            run = "remove";
            desc = "Move to trash";
          }
          {
            on = "D";
            run = "remove --permanently";
            desc = "Delete permanently";
          }
          {
            on = "a";
            run = "create";
            desc = "Create file or directory";
          }
          {
            on = "r";
            run = "rename";
            desc = "Rename file";
          }

          # Search and filter
          {
            on = "/";
            run = "find";
            desc = "Find files";
          }
          {
            on = "f";
            run = "filter";
            desc = "Filter files";
          }
          {
            on = "F";
            run = "filter --smart";
            desc = "Smart filter";
          }

          # Sorting
          {
            on = [ "," "m" ];
            run = "sort modified --dir-first";
            desc = "Sort by modified time";
          }
          {
            on = [ "," "c" ];
            run = "sort created --dir-first";
            desc = "Sort by created time";
          }
          {
            on = [ "," "e" ];
            run = "sort extension --dir-first";
            desc = "Sort by extension";
          }
          {
            on = [ "," "n" ];
            run = "sort natural --dir-first";
            desc = "Sort naturally";
          }
          {
            on = [ "," "s" ];
            run = "sort size --dir-first";
            desc = "Sort by size";
          }

          # DevOps specific shortcuts
          {
            on = [ "g" "d" ];
            run = "cd ~/Projects";
            desc = "Go to Projects directory";
          }
          {
            on = [ "g" "c" ];
            run = "cd ~/.config";
            desc = "Go to config directory";
          }
          {
            on = [ "g" "t" ];
            run = "cd /tmp";
            desc = "Go to temp directory";
          }
          {
            on = [ "g" "D" ];
            run = "cd ~/Downloads";
            desc = "Go to Downloads";
          }

          # Toggle features
          {
            on = "z";
            run = "plugin zoxide";
            desc = "Jump with zoxide";
          }
          {
            on = "T";
            run = "toggle sort_sensitive";
            desc = "Toggle case sensitivity";
          }

          # Custom plugins from Pop!_OS
          {
            on = "s";
            run = "plugin searchjump";
            desc = "Search and jump to file";
          }
          {
            on = [ "'" ];
            run = "plugin bookmarks --args=save";
            desc = "Save bookmark";
          }
          {
            on = [ "\"" ];
            run = "plugin bookmarks --args=jump";
            desc = "Jump to bookmark";
          }
          {
            on = [ "b" "d" ];
            run = "plugin bookmarks --args=delete";
            desc = "Delete bookmark";
          }
        ];
      };

      # Theme configuration handled by Catppuccin module
      # To change theme: modify modules/themes/default.nix
    };

    # Shell aliases for yazi
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      y = "yazi"; # Quick launch
      yy = "yazi ."; # Open in current directory
      yh = "yazi ~"; # Open in home
      yc = "yazi ~/.config"; # Open config directory
      yp = "yazi ~/Projects"; # Open projects directory
      yd = "yazi ~/Downloads"; # Open downloads
      yt = "yazi /tmp"; # Open temp directory
      
      # Educational alias for muscle memory from Pop!_OS
      ya = "echo '⚠️  NixOS Tip: Yazi plugins are managed declaratively via nix!' && echo 'To update: just upgrade macbook' && echo 'Edit: modules/apps/yazi.nix'";
    };

    programs.bash.shellAliases = lib.mkIf config.programs.bash.enable {
      y = "yazi";
      yy = "yazi .";
      yh = "yazi ~";
      yc = "yazi ~/.config";
      yp = "yazi ~/Projects";
      yd = "yazi ~/Downloads";
      yt = "yazi /tmp";
    };

    programs.fish.shellAliases = lib.mkIf config.programs.fish.enable {
      y = "yazi";
      yy = "yazi .";
      yh = "yazi ~";
      yc = "yazi ~/.config";
      yp = "yazi ~/Projects";
      yd = "yazi ~/Downloads";
      yt = "yazi /tmp";
    };

    # Install custom plugins not available in nixpkgs
    home.file.".config/yazi/plugins/searchjump.yazi" = {
      source = searchjump;
      recursive = true;
    };

    home.file.".config/yazi/plugins/starship.yazi" = {
      source = starship;
      recursive = true;
    };

    home.file.".config/yazi/plugins/bookmarks.yazi" = {
      source = bookmarks;
      recursive = true;
    };

    # Catppuccin flavor (matching your Pop!_OS setup)
    home.file.".config/yazi/flavors/catppuccin-macchiato.yazi" = {
      source = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "flavors";
        rev = "4a1802a296ca33b65f56be8349b089a7e19ff485";
        sha256 = "sha256-0000000000000000000000000000000000000000000=";  # Will fail and show correct hash
      } + "/catppuccin-macchiato.yazi";
      recursive = true;
    };
  };
}
