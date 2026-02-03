# modules/apps/wezterm.nix
# WezTerm terminal emulator (backup/reserve option)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.wezterm.enable {
    # ========================================
    # WezTerm (Home Manager)
    # ========================================
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    programs.wezterm = {
      enable = true;
      
      extraConfig = ''
        -- =============================================================================
        -- WezTerm Configuration - Optimized & Lightweight
        -- Based on PopOS config with performance improvements
        -- =============================================================================

        local wezterm = require("wezterm")
        local config = wezterm.config_builder and wezterm.config_builder() or {}

        -- =============================================================================
        -- Platform detection
        -- =============================================================================

        local is_linux = wezterm.target_triple:find("linux")

        -- =============================================================================
        -- Constants
        -- =============================================================================

        local window_background_opacity = 0.90  -- Mesma opacidade do Alacritty

        -- =============================================================================
        -- Utility functions
        -- =============================================================================

        local function toggle_window_background_opacity(window)
          local overrides = window:get_config_overrides() or {}
          if overrides.window_background_opacity then
            overrides.window_background_opacity = nil
          else
            overrides.window_background_opacity = 1.0
          end
          window:set_config_overrides(overrides)
        end
        wezterm.on("toggle-window-background-opacity", toggle_window_background_opacity)

        local function toggle_ligatures(window)
          local overrides = window:get_config_overrides() or {}
          if overrides.harfbuzz_features then
            overrides.harfbuzz_features = nil
          else
            overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
          end
          window:set_config_overrides(overrides)
        end
        wezterm.on("toggle-ligatures", toggle_ligatures)

        -- =============================================================================
        -- Startup
        -- =============================================================================

        config.default_prog = { "${pkgs.zsh}/bin/zsh", "-l" }
        config.skip_close_confirmation_for_processes_named = { "tmux", "zsh", "bash" }

        -- =============================================================================
        -- Appearance - Otimizado para leveza
        -- =============================================================================

        -- Fonte: mesma do Alacritty
        config.font = wezterm.font_with_fallback({
          "JetBrainsMono Nerd Font",
          "DepartureMono Nerd Font",
        })
        config.font_size = 10.0  -- Mesmo tamanho do Alacritty

        -- Tema Catppuccin Mocha (tema escuro padrão)
        config.color_scheme = "Catppuccin Mocha"

        -- Transparência e blur (mesmos valores do Alacritty)
        config.window_background_opacity = window_background_opacity
        config.enable_wayland = true  -- Melhor performance no Wayland
        
        -- Decorações minimalistas
        config.window_decorations = "RESIZE"
        config.hide_tab_bar_if_only_one_tab = true
        config.use_fancy_tab_bar = false

        -- =============================================================================
        -- Performance - Otimizado para velocidade e leveza
        -- =============================================================================

        -- FPS otimizado para balanço performance/bateria
        config.max_fps = 60  -- Reduzido de 120 para economia
        config.animation_fps = 30  -- Reduzido para menor uso de GPU
        
        -- Scrollback reduzido para menor uso de memória
        config.scrollback_lines = 5000  -- Mesmo do Alacritty
        
        -- Desabilitar animações desnecessárias
        config.cursor_blink_rate = 0  -- Cursor sem piscar (menos processamento)
        
        -- Cache de shaped glyphs para melhor performance
        config.allow_square_glyphs_to_overflow_width = "Never"

        -- =============================================================================
        -- Layout & behavior
        -- =============================================================================

        config.window_padding = {
          left = 8,
          right = 8,
          top = 8,
          bottom = 8,
        }

        config.default_cwd = wezterm.home_dir
        config.enable_scroll_bar = false
        config.adjust_window_size_when_changing_font_size = false
        config.window_close_confirmation = "NeverPrompt"

        config.inactive_pane_hsb = {
          saturation = 0.8,
          brightness = 0.7,
        }

        -- Dimensões iniciais (similar ao Alacritty)
        config.initial_cols = 105
        config.initial_rows = 30

        -- =============================================================================
        -- Keybindings - Compatíveis com Alacritty
        -- =============================================================================

        config.keys = {
          -- Toggles
          { 
            key = "O", 
            mods = "CTRL|SHIFT", 
            action = wezterm.action.EmitEvent("toggle-window-background-opacity") 
          },
          { 
            key = "E", 
            mods = "CTRL|SHIFT", 
            action = wezterm.action.EmitEvent("toggle-ligatures") 
          },

          -- Copy/Paste (compatível com Alacritty)
          { 
            key = "C", 
            mods = "CTRL|SHIFT", 
            action = wezterm.action.CopyTo("Clipboard") 
          },
          { 
            key = "V", 
            mods = "CTRL|SHIFT", 
            action = wezterm.action.PasteFrom("Clipboard") 
          },

          -- Font size
          { 
            key = "0", 
            mods = "CTRL", 
            action = wezterm.action.ResetFontSize 
          },
          { 
            key = "=", 
            mods = "CTRL", 
            action = wezterm.action.IncreaseFontSize 
          },
          { 
            key = "-", 
            mods = "CTRL", 
            action = wezterm.action.DecreaseFontSize 
          },

          -- Fullscreen
          { 
            key = "F11", 
            mods = "NONE", 
            action = wezterm.action.ToggleFullScreen 
          },

          -- Spawn window without tmux
          {
            key = "N",
            mods = "CTRL|SHIFT",
            action = wezterm.action.SpawnWindow,
          },

          -- Edit config
          {
            key = ",",
            mods = "CTRL",
            action = wezterm.action.SpawnCommandInNewWindow({
              args = { 
                "${pkgs.zsh}/bin/zsh", 
                "-l", 
                "-c", 
                "cd ~/.config/wezterm && $EDITOR wezterm.lua" 
              },
            }),
          },
        }

        -- =============================================================================
        -- Return config
        -- =============================================================================

        return config
      '';
    };
  };
}
