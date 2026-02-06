# DankMaterialShell Configuration for Niri

This module configures **DankMaterialShell (DMS)** for the Wayland compositor **Niri** with the **Catppuccin Mocha** theme.

## 🎨 What is DankMaterialShell?

DankMaterialShell is a modern and highly customizable shell for Wayland environments, providing:

- 🎯 Top bar with modular widgets
- 🖥️ Advanced workspace management
- 🎵 Integrated media player with audio visualizer
- 🌡️ System monitoring (CPU, RAM, temperature)
- 🔔 Notification center
- ⚙️ Control center for quick settings
- 🎨 Theme support (using Catppuccin)

## 📦 Installation

### Option 1: Using Nix Flake (Recommended)

If DankMaterialShell is available as a Nix package:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dank-material-shell.url = "github:dank-os/dank-material-shell";
  };
}
```

### Option 2: Manual Build

1. Clone the DankMaterialShell repository:
```bash
git clone https://github.com/dank-os/dank-material-shell.git
cd dank-material-shell
```

2. Follow the project's build instructions

3. Install the binary in `~/.local/bin/` or `/usr/local/bin/`

## ⚙️ Current Configuration

The configuration is located at:
- **Main Module**: `modules/desktops/niri/dank-material-shell.nix`
- **Autostart**: `modules/desktops/niri/dms-autostart.nix`
- **Config file**: `~/.config/DankMaterialShell/config.json`

### Configured Features

#### 🎨 Theme
- **Theme**: Catppuccin Mocha
- **Corner Radius**: 12px
- **Transparency**: 95%
- **Gaps**: 8px
- **Borders**: 2px with primary color

#### 📊 Top Bar Widgets

**Left:**
- 🚀 App launcher button
- 🗂️ Workspace selector
- 🪟 Focused window

**Center:**
- 🕐 Clock (24h format with seconds)
- ☀️ Weather

**Right:**
- 🎵 Music player with visualizer
- 📋 Clipboard
- 💾 Disk usage
- 🔥 CPU usage
- 🧠 Memory usage
- 🔔 Notifications
- ⚙️ Control center

#### 🎛️ Control Center

Available widgets:
- 🔊 Volume control
- ☀️ Brightness control
- 📶 Wi-Fi
- 📞 Bluetooth
- 🔈 Audio output
- 🎤 Audio input
- 🌙 Night mode
- 🌓 Dark/light mode

#### ⚡ Power Management

**On AC (Plugged in):**
- Turn off monitor: 15 min
- Lock screen: 30 min
- Profile: Performance

**On Battery:**
- Turn off monitor: 5 min
- Lock screen: 10 min
- Suspend: 30 min
- Profile: Power Saver
- Charge limit: 80%

#### 🔔 Notifications

- Low priority timeout: 3s
- Normal timeout: 5s
- Critical timeout: No timeout
- History: Up to 100 notifications (7 days)
- Position: Top-right

#### 🎨 Fonts

- **Primary**: JetBrainsMono Nerd Font (weight 600, scale 1.15)
- **Monospace**: JetBrainsMono Nerd Font Mono

## 🔧 Customization

### Change Theme

Edit the configuration file at `~/.config/DankMaterialShell/config.json`:

```json
{
  "currentThemeName": "catppuccin-mocha",
  "currentThemeCategory": "registry"
}
```

Available themes:
- `catppuccin-mocha` (default)
- `catppuccin-macchiato`
- `catppuccin-frappe`
- `catppuccin-latte`

### Add/Remove Widgets

In the configuration file, modify the `leftWidgets`, `centerWidgets`, and `rightWidgets` sections:

```json
{
  "barConfigs": [{
    "leftWidgets": [
      { "id": "launcherButton", "enabled": true },
      { "id": "workspaceSwitcher", "enabled": true }
    ]
  }]
}
```

### Adjust Transparency

```json
{
  "popupTransparency": 0.95,
  "dockTransparency": 0.95,
  "transparency": 0.95
}
```

### Configure System Monitoring

To enable the System Monitor widget:

```json
{
  "systemMonitorEnabled": true,
  "systemMonitorShowCpu": true,
  "systemMonitorShowMemory": true,
  "systemMonitorShowNetwork": true,
  "systemMonitorShowDisk": true
}
```

## 🔄 Integration with Niri

DMS is configured to work with Niri through:

1. **Environment variables**:
   - `DMS_COMPOSITOR=niri`
   - `DMS_THEME=catppuccin-mocha`

2. **Layout settings**:
   - Gaps: 8px
   - Border radius: 12px
   - Border size: 2px

3. **Matugen templates**: Enabled to sync colors with:
   - GTK
   - Qt5/Qt6
   - Alacritty
   - Firefox
   - VSCode

## 🚀 Usage

### Quick Shortcuts

Niri shortcuts continue to work normally. See [keybindings.nix](keybindings.nix).

### DMS Commands

- **Open App Launcher**: `Mod+D` or click the launcher button
- **Open Control Center**: Click the gear icon
- **Open Notifications**: Click the bell icon
- **Clipboard History**: Click the clipboard icon

### Workspace Management

- **Scroll on the bar**: Navigate between workspaces
- **Click a workspace**: Switch to that workspace
- **Drag a window**: Move window between workspaces

## 🎨 Custom Themes

To create a custom theme:

1. Create a file at `~/.config/DankMaterialShell/themes/my-theme/theme.json`:

```json
{
  "name": "My Theme",
  "colors": {
    "primary": "#cba6f7",
    "secondary": "#f5c2e7",
    "background": "#1e1e2e",
    "surface": "#313244",
    "text": "#cdd6f4"
  }
}
```

2. Update the configuration:

```json
{
  "currentThemeName": "custom",
  "customThemeFile": "/home/your-user/.config/DankMaterialShell/themes/my-theme/theme.json"
}
```

## 🐛 Troubleshooting

### DMS does not start

1. Check if DMS is installed:
```bash
which dank-material-shell
```

2. Check logs:
```bash
journalctl --user -u dank-material-shell
```

3. Start manually for debugging:
```bash
dank-material-shell --debug
```

### Widgets do not appear

1. Check the JSON configuration
2. Make sure the required services are running:
```bash
systemctl --user status pipewire wireplumber
```

### Theme does not apply

1. Clear the cache:
```bash
rm -rf ~/.cache/DankMaterialShell
```

2. Restart DMS:
```bash
pkill dank-material-shell
dms-start
```

## 📚 Resources

- [DMS Official Documentation](https://github.com/dank-os/dank-material-shell)
- [Niri Documentation](https://github.com/YaLTeR/niri)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)

## 🤝 Contributing

If you make improvements to this configuration, consider:
1. Testing thoroughly
2. Documenting the changes
3. Sharing with the community

## 📝 Notes

- This configuration keeps Waybar as a fallback
- DMS and Waybar can coexist, but only one should be active at a time
- To disable DMS, edit `dank-material-shell.nix` and set `isMacbook = false`
- To go back to Waybar, disable DMS autostart

## 🔄 Updates

To update this configuration:

```bash
# System rebuild
sudo nixos-rebuild switch --flake .#macbook

# Or home-manager only
home-manager switch --flake .#borba@macbook-nixos
```

---

**Configuration created with ❤️ using NixOS and Catppuccin**
