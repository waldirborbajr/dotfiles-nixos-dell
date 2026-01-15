# Tmux Configuration

> Opinionated tmux setup focused on **productivity, persistence and low friction**.
> Designed to work seamlessly with **Alacritty**, **Neovim**, and modern DevOps workflows.

---

## ✨ Highlights

- Prefix key remapped to **Ctrl-a**
- Vim-style pane navigation
- Path-aware splits (new panes open in the same directory)
- Tokyo Night theme (plugin-based)
- Clipboard integration
- **Session persistence with tmux-resurrect + tmux-continuum**
- Automatic restore on startup
- Works on **Linux, macOS, NixOS**

---

## 📦 Requirements

- tmux ≥ 3.2 (recommended)
- git

Optional but recommended:
- Alacritty
- Neovim
- Zsh

---

## 🔧 Installation

### Install tmux

```sh
# Arch Linux
sudo pacman -S tmux

# Ubuntu / Debian
sudo apt install tmux

# macOS
brew install tmux
```

### Clone this repository

```sh
git clone https://github.com/your-user/your-tmux-repo.git
```

### Symlink configuration

```sh
mkdir -p ~/.config/tmux
ln -sf /path/to/repo/tmux.conf ~/.config/tmux/tmux.conf
```

Reload tmux:

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

---

## 🔌 Plugins (TPM)

This setup uses **TPM – Tmux Plugin Manager**.

Plugins in use:

- `tmux-plugins/tpm`
- `tmux-plugins/tmux-sensible`
- `joshmedeski/vim-tmux-navigator`
- `tmux-plugins/tmux-yank`
- `janoamaral/tokyo-night-tmux`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`

### Install plugins

Inside tmux:

```
Prefix + I
```

---

## ♻️ Session Persistence

### tmux-resurrect

Restores:

- Sessions
- Windows and panes
- Layouts
- Working directories
- Commands (ssh, kubectl, nvim, etc.)

Manual commands:

| Action | Shortcut |
|------|---------|
| Save session | `Prefix + Ctrl + s` |
| Restore session | `Prefix + Ctrl + r` |

### tmux-continuum

- Automatically saves sessions every **10 minutes**
- Automatically restores sessions on tmux startup

No manual interaction required 🚀

---

## 🧭 Keybindings

### Prefix

| Key | Action |
|----|------|
| `Ctrl-a` | tmux prefix |

---

### Pane navigation (Vim-style)

| Key | Action |
|----|------|
| `Prefix + h/j/k/l` | Move between panes |
| `Ctrl + h/j/k/l` | Move between panes (Neovim ↔ tmux) |

---

### Splits (path-aware)

| Key | Action |
|----|------|
| `Prefix + \\` | Horizontal split |
| `Prefix + -` | Vertical split |

New panes open in the **current working directory**.

---

### Resize panes

| Key | Action |
|----|------|
| `Prefix + ← / →` | Resize horizontally |
| `Prefix + ↑ / ↓` | Resize vertically |
| `Prefix + m` | Toggle zoom |

---

### Window navigation

| Key | Action |
|----|------|
| `Shift + ← / →` | Previous / next window |
| `Alt + H / L` | Previous / next window |

---

### Copy mode (vi)

| Key | Action |
|----|------|
| `Prefix + [` | Enter copy mode |
| `v` | Start selection |
| `Ctrl + v` | Rectangle selection |
| `y` | Yank selection |

Clipboard is integrated with the system via `tmux-yank`.

---

### Reload config

| Key | Action |
|----|------|
| `Prefix + r` | Reload tmux config |

---

## 🎨 Theme

This configuration uses **Tokyo Night** via plugin:

- Clean status bar
- Relative path display
- Minimal Git indicators
- No visual clutter

Theme options are configured directly in `tmux.conf` using plugin variables.

---

## 🧠 Design Philosophy

- Minimal friction
- Keyboard-first
- Vim-centric workflow
- Persistent state (never lose context)
- Declarative-friendly (works great with dotfiles / Nix)

---

## 🚀 Recommended Setup

Works best with:

- Alacritty autostarting tmux
- Neovim with sessions enabled
- Zsh + starship

---

## 📌 Notes

- This is **not** a zero-plugin setup by design
- Plugins are used intentionally to remove manual session management
- If you prefer a minimal tmux without plugins, this repo may not be for you

---

## 🧑‍💻 Author

Maintained by **Tony**  
Adapted and modernized with a DevOps/SRE workflow in mind.

---

## Shortcut

* Instalar plugins `Prefix + I` 
* Atualizar plugins `Prefix + U` 
* Remover plugins `Prefix + alt + u` 

Happy hacking 🧠⚡

