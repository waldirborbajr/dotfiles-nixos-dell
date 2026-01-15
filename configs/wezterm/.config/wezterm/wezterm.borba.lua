--
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
-- A GPU-accelerated cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/

-- Pull in WezTerm API
local wezterm = require("wezterm")

-- =============================================================================
-- Platform detection
-- =============================================================================

local is_macos = wezterm.target_triple:find("apple")
local is_linux = wezterm.target_triple:find("linux")

-- =============================================================================
-- Constants
-- =============================================================================

local window_background_opacity = 0.9

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
-- Color scheme
-- =============================================================================

local function color_scheme()
	if is_macos then
		local appearance = wezterm.gui.get_appearance()
		if appearance:find("Dark") then
			return "Catppuccin Mocha"
		else
			return "Catppuccin Latte"
		end
	end

	-- Linux / fallback
	return "Catppuccin Mocha"
end

-- =============================================================================
-- Config initialization
-- =============================================================================

local config = wezterm.config_builder and wezterm.config_builder() or {}

-- =============================================================================
-- Startup
-- =============================================================================

config.default_prog = { "/bin/zsh", "-l", "-c", "--", "tmux new -As base" }
config.skip_close_confirmation_for_processes_named = { "tmux" }

-- =============================================================================
-- Appearance
-- =============================================================================

config.font = wezterm.font_with_fallback({
	"JetBrains Mono Nerd Font",
	"DepartureMono Nerd Font",
})
config.font_size = 11.0
config.color_scheme = color_scheme()
config.window_background_opacity = window_background_opacity
config.window_decorations = "RESIZE"

if is_macos then
	config.macos_window_background_blur = 10
	config.native_macos_fullscreen_mode = false
end

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- =============================================================================
-- Performance
-- =============================================================================

config.max_fps = 120
config.animation_fps = 60
config.scrollback_lines = 10000

-- =============================================================================
-- Layout & behavior
-- =============================================================================

config.window_padding = {
	left = 5,
	right = 0,
	top = 5,
	bottom = 0,
}

config.default_cwd = wezterm.home_dir
config.enable_scroll_bar = false
config.adjust_window_size_when_changing_font_size = false
-- config.window_close_confirmation = "NeverPrompt"

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

-- =============================================================================
-- Keybindings
-- =============================================================================

config.keys = {
	-- Toggles
	{ key = "O", mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-window-background-opacity") },
	{ key = "E", mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-ligatures") },

	-- Edit config (macOS / Linux safe)
	{
		key = ",",
		mods = is_macos and "SUPER" or "CTRL",
		action = wezterm.action.SpawnCommandInNewWindow({
			cwd = os.getenv("WEZTERM_CONFIG_DIR"),
			args = {
				os.getenv("SHELL"),
				"-l",
				"-c",
				'eval "$(mise env zsh)" && source "$XDG_DATA_HOME/bob/env/env.sh" && $VISUAL $WEZTERM_CONFIG_FILE',
			},
		}),
	},

	-- Spawn window without tmux
	{
		key = ">",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewWindow({
			args = { os.getenv("SHELL"), "-l", "-c", "zsh" },
		}),
	},

	-- Window management
	{ key = "n", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "n", mods = "CTRL|SHIFT", action = wezterm.action.SpawnWindow },
}

-- =============================================================================
-- Return config
-- =============================================================================

return config
