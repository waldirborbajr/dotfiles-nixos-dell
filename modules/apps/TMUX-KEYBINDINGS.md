# 🎯 Tmux Keybindings - DevOps Edition

> **Prefix**: `Ctrl-a` (All bindings require pressing prefix first, unless specified)

## 📋 Quick Reference

### 🪟 Window Management
| Key | Action |
|-----|--------|
| `c` | New window (in current path) |
| `C` | Kill current window |
| `H` | Previous window |
| `L` | Next window |
| `Tab` / `Ctrl-a` | Last window |
| `r` | Rename window |
| `w` | List windows |
| `"` | Choose window from list |

### 📐 Pane Management
| Key | Action |
|-----|--------|
| `v` / `\|` | Split vertically |
| `s` / `-` | Split horizontally |
| `h/j/k/l` | Navigate panes (vim-style) |
| `,` `.` | Resize pane left/right (10px, repeatable) |
| `-` `=` | Resize pane down/up (5px, repeatable) |
| `<` `>` | Resize pane left/right (20px, repeatable) |
| `_` `+` | Resize pane down/up (10px, repeatable) |
| `z` | Toggle zoom pane |
| `x` | Kill pane (no confirmation) |
| `X` | Swap pane with next |
| `B` | Break pane to new window |
| `J` | Join pane to window 1 |

### 🎮 Session Management
| Key | Action |
|-----|--------|
| `K` | Fuzzy session switcher (sesh + fzf) |
| `l` | Last session |
| `S` | Choose session |
| `Q` | Kill current session |
| `d` / `Ctrl-d` | Detach from session |

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
| `*` | Synchronize panes (toggle) |
| `P` | Toggle pane borders |
| `e` | Open pane history in Neovim |
| `:` | Command prompt |
| `?` | List all keybindings |

## 🔍 Sesh Session Switcher

When you press `prefix + K`, you get a fuzzy finder with these keybindings:

| Key | Filter |
|-----|--------|
| `Ctrl-a` | All sessions |
| `Ctrl-t` | Tmux windows only |
| `Ctrl-g` | Config directories |
| `Ctrl-x` | Zoxide (frecent directories) |
| `Ctrl-f` | Find directories |
| `Ctrl-d` | Delete session |

## 🎨 Color Scheme

- **Active pane**: Magenta border
- **Inactive pane**: Bright black border
- **Current window**: Magenta, bold
- **Status bar**: Transparent background, top position

## 📦 Plugins (TPM)

After first setup, install plugins:
1. Press `prefix + I` to install plugins
2. Press `prefix + U` to update plugins
3. Press `prefix + alt + u` to uninstall plugins

### Installed Plugins:
- **tmux-sensible**: Basic tmux settings
- **tmux-yank**: Clipboard integration
- **tmux-resurrect**: Session persistence
- **tmux-continuum**: Auto-save sessions
- **vim-tmux-navigator**: Seamless vim/tmux navigation
- **tmux-fzf**: Fuzzy finder integration
- **tmux-fzf-url**: Open URLs from terminal

## 💡 Pro Tips

1. **Nested tmux**: Press `Ctrl-a` twice to send prefix to nested session
2. **Mouse support**: Enabled - click to select panes, drag borders to resize
3. **Copy to system clipboard**: Selections are automatically copied
4. **Session persistence**: Sessions auto-save every 15 minutes
5. **Vim integration**: Use same navigation keys between vim and tmux

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
- **Copy not working**: Ensure `xclip` or `wl-clipboard` is installed
- **Plugins not loading**: Run `prefix + I` to install TPM plugins
- **Can't find sesh**: Check if `sesh` is in PATH with `which sesh`

## 📚 Further Reading

- [Tmux Manual](https://man.openbsd.org/tmux)
- [Sesh Documentation](https://github.com/joshmedeski/sesh)
- [TPM Plugins](https://github.com/tmux-plugins)
