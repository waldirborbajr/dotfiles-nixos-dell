# 🔄 Atualização da Configuração Niri - Resumo das Mudanças

## 📅 Data: 28 de Janeiro de 2026

## 🎯 Objetivo
Adicionar keybindings e configurações faltantes no Niri, usando uma configuração de referência completa.

---

## 📝 Arquivos Modificados

### 1. **keybindings.nix** - MAJOR UPDATE
Adicionadas **50+ novas teclas** e keybindings:

#### Aplicações Novas
- `Mod+Shift+Return` - Launcher Rofi
- `Mod+W` - Abrir Brave browser
- `Mod+E` - Abrir Emacs (emacsclient)
- `Mod+Alt+Minus` - Lock screen (swaylock)

#### Overview & Session
- `Mod+O` - Toggle Overview (zoomed-out view)
- `Mod+Shift+Q` - Quit Niri (alternativa)
- `Ctrl+Alt+P` - Power off monitors
- `Mod+Escape` - Toggle keyboard shortcuts inhibit (escape hatch)

#### Window Focus Melhorado
- `Mod+J/K` agora usa `focus-window-or-workspace-down/up`
- `Mod+Home/End` - Focus first/last column
- `Mod+Comma/Period` - Focus monitor previous/next

#### Window Movement Avançado
- `Mod+Shift+H/L` usa `move-column-left-or-to-monitor-left/right`
- `Mod+Shift+J/K` usa `move-column-to-workspace-down/up`
- `Mod+Ctrl+Home/End` - Move column to first/last
- `Mod+Ctrl+U/I` - Move workspace down/up

#### Mouse Wheel Support
- `Mod+WheelScroll` - Navigate workspaces/columns
- `Mod+Ctrl+WheelScroll` - Move windows
- `Mod+Shift+WheelScroll` - Navigate columns horizontally
- Cooldown de 150ms para smooth scrolling

#### Column Management
- `Mod+Shift+R` - Switch preset window height
- `Mod+Ctrl+R` - Reset window height
- `Mod+Ctrl+F` - Expand column to available width
- `Mod+Ctrl+C` - Center visible columns
- `Mod+Alt+H/L` - Consume or expel window left/right
- `Mod+T` - Toggle tabbed display mode

#### Floating Windows
- `Mod+V` - Toggle floating (mantido)
- `Mod+Shift+V` - Switch focus between floating/tiling
- `Mod+Shift+Space` - Toggle floating (alternativa)

#### Close Window
- `Mod+Q` - Close window (mantido)
- `Mod+Shift+C` - Close window (alternativa)

#### Screenshots
- `Mod+apostrophe` (') - Screenshot screen
- `Mod+Alt+apostrophe` - Screenshot window
- `Mod+Shift+apostrophe` - Screenshot (área)

#### Workspace Movement
- `Mod+Ctrl+1-9` - Move column to workspace (adicionado)
- `Mod+Shift+1-9` - Move column to workspace (mantido)

#### Media Keys com Lock Support
Todos os media keys agora têm `allow-when-locked=true`:
- Volume keys: 10% increment (era 5%)
- Brightness: 10% increment com `--class=backlight`
- Player controls: Usa `spawn-sh` para `playerctl`
- `XF86AudioStop` - Adicionar stop command

#### Hotkey Overlays
Adicionados `hotkey-overlay-title` em vários binds para melhor documentação

---

### 2. **input.nix** - UPDATED

#### Adicionado:
- `numlock` - Enable numlock on startup
- `focus-follows-mouse max-scroll-amount="0%"` - Focus only fully visible windows

---

### 3. **layout.nix** - MAJOR UPDATE

#### Layout Settings
- `gaps 14` (era 8)
- `center-focused-column "never"` (era "on-overflow")
- `focus-ring width 3` (era 2)
- Cores ajustadas para tema original (#7fc8ff e #282c34)

#### Shadow Adicionado
```kdl
shadow {
  on
  softness 30
  spread 5
  offset x=0 y=5
  color "#0007"
}
```

#### Cursor
- `hide-when-typing` - Oculta cursor ao digitar

#### Gestures
```kdl
gestures {
  hot-corners {
    off  // Desabilita toggle-overview no canto
  }
}
```

#### Environment Variables
- `DISPLAY ":1"` - Para compatibilidade Java
- `_JAVA_AWT_WM_NONREPARENTING "1"` - Fix Java apps

#### Startup Apps MAJOR CHANGES
**Removido:** `swaybg` direto

**Adicionado:**
- `swayidle` - Auto power-off monitors after 600s
- `waypaper --backend swaybg --restore` - Wallpaper manager
- `spawn-sh-at-startup "dms run"` - **DankMaterialShell**
- `/usr/bin/emacs --daemon` - Emacs server

---

### 4. **window-rules.nix** - UPDATED

#### Novas Window Rules

**Open Maximized:**
- `audacity`
- `brave-browser`
- `discord`
- `gimp`
- `kdenlive`
- `qutebrowser`
- `tasty.javafx.launcher.LauncherFxApp` (com títulos específicos)

**Open Floating:**
- `qalculate-gtk`
- `tasty.javafx.launcher.LauncherFxApp` (Dashboard e Portfolio Report)

**Global Rule:**
```kdl
window-rule {
  geometry-corner-radius 6
  clip-to-geometry true
}
```
Aplica cantos arredondados em **todas** as janelas

---

### 5. **config.nix** - UPDATED
Adicionado include para `dms/cursor.kdl`

---

### 6. **dms-cursor.nix** - NEW FILE ✨
Novo módulo para configuração de cursor do DMS
- Preparado para configurações futuras específicas do DMS

---

### 7. **default.nix** - UPDATED
Adicionado import: `./dms-cursor.nix`

---

## 🆕 Recursos Adicionados

### ✅ Funcionalidades Principais

1. **Overview Mode** (`Mod+O`)
   - Vista zoomed-out de workspaces e janelas

2. **Mouse Wheel Navigation**
   - Scroll smooth entre workspaces/colunas
   - Cooldown de 150ms

3. **Monitor Management**
   - Foco entre múltiplos monitores
   - Movimento de janelas entre monitores

4. **Column Management Avançado**
   - Consume/expel windows
   - Tabbed display mode
   - Expand to available width
   - Center visible columns

5. **Floating & Tiling**
   - Switch focus entre floating/tiling
   - Múltiplos atalhos para toggle

6. **Escape Hatches**
   - `Mod+Escape` - Desabilita shortcuts (anti-lockout)
   - `allow-inhibiting=false` para binds críticos

7. **DankMaterialShell Integration**
   - Auto-start via `spawn-sh-at-startup "dms run"`
   - Cursor config preparado

8. **Java Apps Support**
   - Environment variables para compatibilidade

9. **Power Management**
   - Auto power-off monitors após 10min (swayidle)

10. **Screenshot Variants**
    - Screen, Window, Area com apostrophe key

---

## 🔧 Alterações de Comportamento

### Volume
- **Antes:** Incremento de 5%
- **Agora:** Incremento de 10% com limite em 1.0

### Brightness
- **Antes:** Simple `brightnessctl set 5%+/-`
- **Agora:** `brightnessctl --class=backlight set 10%+/-`

### Focus
- **Antes:** `focus-window-down/up`
- **Agora:** `focus-window-or-workspace-down/up` (navega entre workspaces)

### Movement
- **Antes:** `move-column-left/right`
- **Agora:** `move-column-left-or-to-monitor-left/right` (move entre monitores)

### Gaps
- **Antes:** 8px
- **Agora:** 14px

### Focus Ring
- **Antes:** 2px width
- **Agora:** 3px width

---

## 📋 Checklist de Testes

Após rebuild, testar:

- [ ] `Mod+O` - Overview funciona
- [ ] `Mod+Shift+Return` - Rofi launcher abre
- [ ] `Mod+W` - Brave abre
- [ ] `Mod+E` - Emacs abre
- [ ] `Mod+Alt+Minus` - Swaylock ativa
- [ ] Mouse wheel scroll navega workspaces
- [ ] `Mod+Comma/Period` troca monitores (se múltiplos)
- [ ] `Mod+T` ativa tabbed mode
- [ ] `Mod+Ctrl+F` expande coluna
- [ ] `Mod+V` toggle floating
- [ ] `Mod+Shift+V` switch floating/tiling
- [ ] `Mod+apostrophe` screenshots
- [ ] Media keys funcionam na tela de lock
- [ ] Brightness +10% por pressão
- [ ] Volume +10% por pressão com limite
- [ ] Swayidle auto-desliga monitor após 10min
- [ ] DMS inicia automaticamente
- [ ] Cursor oculta ao digitar
- [ ] Cantos arredondados em todas as janelas
- [ ] Shadows aparecem nas janelas
- [ ] Hot corner desabilitado (não abre overview no canto)
- [ ] Numlock ativa no boot

---

## 🚀 Para Aplicar

```bash
# Rebuild do sistema
sudo nixos-rebuild switch --flake .#macbook

# OU apenas home-manager
home-manager switch --flake .#borba@macbook-nixos

# Logout/Login para aplicar completamente
```

---

## 📚 Referências

- Configuração base: `/workspaces/nixos-config/modules/desktops/niri/`
- Documentação Niri: https://yalter.github.io/niri/
- KDL Format: https://kdl.dev

---

## 💡 Notas Importantes

1. **Conflito Resolvido:** `Mod+Shift+P` mantido para power-off-monitors (rofi-pass não adicionado)
2. **Dual Bindings:** Vários comandos têm 2+ atalhos para flexibilidade
3. **Lock Support:** Media keys funcionam mesmo com tela bloqueada
4. **DMS Ready:** Configuração preparada para DankMaterialShell
5. **Java Ready:** Environment variables para apps Java problemáticos
6. **Multi-Monitor Ready:** Comandos específicos para múltiplos monitores

---

## ✨ Total de Mudanças

- **50+ novos keybindings**
- **4 arquivos modificados**
- **1 arquivo novo** (dms-cursor.nix)
- **3 seções de configuração expandidas** (layout, input, window-rules)
- **10+ novos recursos** habilitados

---

**Configuração sincronizada com referência e otimizada para NixOS! 🎉**
