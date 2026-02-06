# WezTerm - Terminal Emulator (Backup)

## Status
**Disabled by default** - Available as a backup/alternate option

## Features

### Optimized Performance
WezTerm is configured to be **light and fast**:
- FPS reduced to 60 (performance/battery balance)
- Optimized animations (30 fps)
- Scrollback limited to 5000 lines (memory savings)
- Cursor without blinking (less CPU/GPU work)
- Optimized glyph cache

### Alacritty Compatibility
Keeps the same visual settings as Alacritty:
- **Font**: JetBrainsMono Nerd Font, size 10.0
- **Transparency**: 90% opacity (0.90)
- **Padding**: 8px on all sides
- **Dimensions**: 105 columns x 30 lines
- **Keybindings**: Compatible with Alacritty

### Additional Features
- **Theme**: Catppuccin Mocha (dark)
- **Toggles**:
  - `Ctrl+Shift+O`: Toggle transparency
  - `Ctrl+Shift+E`: Toggle ligatures
- **GPU Accelerated**: Better graphics performance
- **Native Wayland**: Optimized Wayland support

## How to Enable

### Option 1: Via home.nix
```nix
{
  apps.wezterm.enable = true;
}
```

### Option 2: Via hosts/{hostname}.nix
```nix
{
  home-manager.users.borba = {
    apps.wezterm.enable = true;
  };
}
```

### Option 3: Replace Alacritty
```nix
{
  apps = {
    alacritty.enable = false;  # Disable Alacritty
    wezterm.enable = true;      # Enable WezTerm
  };
}
```

## Comparison: WezTerm vs Alacritty

| Feature | WezTerm | Alacritty |
|---------------|---------|-----------|
| **Performance** | Fast (GPU) | Very Fast (GPU) |
| **Memory Usage** | Moderate | Low |
| **Features** | Rich (tabs, splits, lua) | Minimalist |
| **Configuration** | Lua (programmable) | TOML (declarative) |
| **Splits/Tabs** | Native | Via tmux/zellij |
| **Startup** | ~50-100ms | ~20-50ms |
| **Maturity** | New (active) | Mature (stable) |

## Usage Recommendations

### Use WezTerm if you:
- ✅ Want native tabs and splits (no tmux)
- ✅ Need programmable configuration (Lua)
- ✅ Like advanced built-in features
- ✅ Value features over minimalism

### Use Alacritty if you:
- ✅ Prioritize maximum speed and lightness
- ✅ Prefer simplicity and minimalism
- ✅ Already use tmux/zellij for multiplexing
- ✅ Want lower battery consumption

## Original Configuration
Based on the PopOS configuration with optimizations:
- [Original Configuration](https://github.com/waldirborbajr/dotfiles/blob/main/wezterm/.config/wezterm/wezterm.lua)

## Customization

The configuration file is at:
```
modules/apps/wezterm.nix
```

To edit via WezTerm (if enabled):
```bash
Ctrl+, (opens the editor in the configuration)
```

## Main Keybindings

| Shortcut | Action |
|--------|------|
| `Ctrl+Shift+C` | Copy |
| `Ctrl+Shift+V` | Paste |
| `Ctrl+0` | Reset font size |
| `Ctrl+=` | Increase font size |
| `Ctrl+-` | Decrease font size |
| `F11` | Fullscreen |
| `Ctrl+Shift+N` | New window |
| `Ctrl+Shift+O` | Toggle transparency |
| `Ctrl+Shift+E` | Toggle ligatures |
| `Ctrl+,` | Edit config |

## Troubleshooting

### WezTerm does not start
```bash
# Check if it is installed
which wezterm

# Test configuration
wezterm --config-file ~/.config/wezterm/wezterm.lua

# View logs
journalctl --user -u wezterm
```

### Font does not appear correctly
```bash
# List available fonts
fc-list | grep -i "jetbrains"

# Check installed Nerd fonts
nix-shell -p nerdfonts --run "fc-list | grep Nerd"
```

### Poor performance
Adjust in `modules/apps/wezterm.nix`:
```lua
config.max_fps = 30  -- Reduce if needed
config.animation_fps = 15  -- Reduce animations
```

## Alacritty Migration

If you decide to migrate completely:
1. Test WezTerm for a few days with both enabled
2. Adjust keybindings if needed
3. Disable Alacritty when you are comfortable
4. Keep the Alacritty module for an easy rollback

```nix
# Testing phase (both enabled)
apps.alacritty.enable = true;
apps.wezterm.enable = true;

# After deciding to migrate
apps.alacritty.enable = false;
apps.wezterm.enable = true;
```

## Notes
- WezTerm uses more memory than Alacritty (~50-100MB vs ~20-40MB)
- Startup is slightly slower (~2-3x)
- GPU acceleration can consume more battery
- Configuration is optimized for 60 FPS (performance/battery balance)
