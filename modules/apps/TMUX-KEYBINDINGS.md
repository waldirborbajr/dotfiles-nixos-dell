# 🎯 Tmux Keybindings - DevOps Edition

> **Prefix**: `Ctrl-a` (All bindings require pressing prefix first, unless specified)

## 📋 Quick Reference

### 🪟 Window Management
| Key | Action |
|-----|--------|
| `c` | New window (in current path) |
| `Ctrl-c` | New window (in $HOME) |
| `C` | Kill window |
| `H` | Previous window |
| `L` | Next window |
| `Tab` | Last window |
| `Ctrl-a` | Send prefix (for nested tmux) |
| `r` | Rename window |
| `w` / `Ctrl-w` | List windows |

### 📐 Pane Management
| Key | Action |
|-----|--------|
| `v` / `\|` | Split vertically (in current path) |
| `s` / `-` | Split horizontally (in current path) |
| `%` | Split vertically (alternative) |
| `h/j/k/l` | Navigate panes (vim-style) |
| **No prefix:** `Ctrl-h/j/k/l` | Navigate panes (turbo mode) |
| `,` `.` | Resize pane left/right (10px, repeatable) |
| `=` | Resize pane up (5px, repeatable) |
| `_` | Resize pane down (10px, repeatable) |
| `+` | Resize pane up (10px, repeatable) |
| `<` `>` | Resize pane left/right (20px, repeatable) |
| `z` | Toggle zoom pane |
| `x` | Kill pane (no confirmation) |
| `X` | Swap pane with next |
| `B` | Break pane to new window |
| `J` | Join pane to window 1 |

### 🎮 Session Management
| Key | Action |
|-----|--------|
| `S` | Choose session |
| `Q` | Kill current session |
| `d` / `Ctrl-d` | Detach from session |
| `D` | Detach client |
| `*` | List clients |

### 🚀 DevOps Quick Launch
| Key | Action | Icon |
|-----|--------|------|
| `g` | LazyGit | 🌳 |
| `G` | GitHub Dashboard (gh dash) | 😺 |
| `E` | Neovim editor | 📝 |
| `Meta-r` | Rust dev environment | 🦀 |
| `Meta-g` | Go dev environment | 🐹 |
| `Meta-l` | Lua dev environment | 🌙 |
| `Meta-p` | Python dev environment | 🐍 |
| `Meta-n` | Node.js dev environment | 📦 |
| `Meta-d` | Docker CLI | 🐳 |
| `Meta-k` | Kubernetes (kubectl) | ☸️ |
| `Meta-h` | Helix editor | ✨ |
| `Meta-t` | htop | 📊 |
| `Meta-f` | Yazi file manager | 📁 |

### 📝 Copy Mode (Vi-style)
| Key | Action |
|-----|--------|
| `Escape` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy selection |
| `Ctrl-v` | Rectangle selection |
| `p` | Paste buffer |
| `Escape` | Cancel/exit copy mode |

### 🔧 Utilities
| Key | Action |
|-----|--------|
| `R` | Reload config |
| `K` | Clear terminal |
| `P` | Toggle pane borders |
| `e` | Open pane history in Neovim |
| `:` | Command prompt |
| `?` | List all keybindings |
| `Ctrl-x` | Lock server |

## 🎨 Theme - Tokyo Night

- **Theme**: Tokyo Night
- **Status bar**: Bottom position
- **Features**: Path display (relative), window ID style (dsquare)
- **Updates**: Every 5 seconds

## 📦 Plugins (TPM)

After first setup, install plugins:
1. Press `prefix + I` to install plugins
2. Press `prefix + U` to update plugins
3. Press `prefix + alt + u` to uninstall plugins

### Installed Plugins:
- **tmux-sensible**: Basic tmux settings
- **tmux-yank**: Clipboard integration
- **tmux-resurrect**: Session persistence (captures pane contents)
- **tmux-continuum**: Auto-save sessions (every 10 minutes)
- **vim-tmux-navigator**: Seamless vim/tmux navigation
- **tokyo-night-tmux**: Tokyo Night color theme

## 💡 Pro Tips

1. **Nested tmux**: Press `prefix + Ctrl-a` to send prefix to nested session
2. **Mouse support**: Enabled - click to select panes, drag borders to resize
3. **Copy to system clipboard**: Vi-mode selections are automatically copied with tmux-yank
4. **Session persistence**: Sessions auto-save every 10 minutes (tmux-continuum)
5. **Vim integration**: Use `Ctrl-h/j/k/l` to navigate seamlessly between vim splits and tmux panes
6. **No prefix navigation**: Use `Ctrl-h/j/k/l` without prefix for faster pane navigation
7. **Path awareness**: New windows and splits inherit current directory

## 🔗 Language-Specific Workflows

### Rust Development
```bash
prefix + Meta-r  # Open Rust window
cargo watch -x run  # Auto-rebuild on changes
```

### Go Development
```bash
prefix + Meta-g  # Open Go window
air  # Live reload for Go apps
```

### Docker Workflow
```bash
prefix + Meta-d  # Open Docker window
docker compose up  # Start services
prefix + *  # Sync panes to run commands on all containers
```

### Kubernetes
```bash
prefix + Meta-k  # Open K8s window
kubectl get pods -w  # Watch pods
k9s  # Launch K9s TUI
```

## 🆘 Troubleshooting

- **Colors look wrong**: Check `$TERM` is set to `screen-256color`
- **Copy not working**: Ensure clipboard integration is working (xclip/wl-clipboard)
- **Plugins not loading**: Run `prefix + I` to install TPM plugins
- **Navigation not working**: Ensure vim-tmux-navigator is installed in both tmux and vim/neovim
- **Sessions not restoring**: Check if tmux-resurrect and tmux-continuum are installed

## 📚 Further Reading

- [Tmux Manual](https://man.openbsd.org/tmux)
- [TPM Plugins](https://github.com/tmux-plugins)
- [Tokyo Night Theme](https://github.com/janoamaral/tokyo-night-tmux)
- [Vim-Tmux Navigator](https://github.com/joshmedeski/vim-tmux-navigator)
