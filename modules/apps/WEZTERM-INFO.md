# WezTerm - Terminal Emulator (Reserva)

## Status
**Desabilitado por padrão** - Disponível como opção de backup/reserva

## Características

### Performance Otimizada
O WezTerm foi configurado para ser **leve e rápido**:
- FPS reduzido para 60 (balanço performance/bateria)
- Animações otimizadas (30 fps)
- Scrollback limitado a 5000 linhas (economia de memória)
- Cursor sem piscar (menos processamento CPU/GPU)
- Cache de glyphs otimizado

### Compatibilidade com Alacritty
Mantém as mesmas configurações visuais do Alacritty:
- **Fonte**: JetBrainsMono Nerd Font, tamanho 10.0
- **Transparência**: 90% opacidade (0.90)
- **Padding**: 8px em todos os lados
- **Dimensões**: 105 colunas x 30 linhas
- **Keybindings**: Compatíveis com Alacritty

### Recursos Adicionais
- **Tema**: Catppuccin Mocha (escuro)
- **Toggles**: 
  - `Ctrl+Shift+O`: Alternar transparência
  - `Ctrl+Shift+E`: Alternar ligatures
- **GPU Acelerado**: Melhor performance gráfica
- **Wayland Nativo**: Suporte otimizado para Wayland

## Como Habilitar

### Opção 1: Via home.nix
```nix
{
  apps.wezterm.enable = true;
}
```

### Opção 2: Via hosts/{hostname}.nix
```nix
{
  home-manager.users.borba = {
    apps.wezterm.enable = true;
  };
}
```

### Opção 3: Substituir Alacritty
```nix
{
  apps = {
    alacritty.enable = false;  # Desabilitar Alacritty
    wezterm.enable = true;      # Habilitar WezTerm
  };
}
```

## Comparação: WezTerm vs Alacritty

| Característica | WezTerm | Alacritty |
|---------------|---------|-----------|
| **Performance** | Rápido (GPU) | Muito Rápido (GPU) |
| **Uso de Memória** | Moderado | Baixo |
| **Funcionalidades** | Rico (tabs, splits, lua) | Minimalista |
| **Configuração** | Lua (programável) | TOML (declarativo) |
| **Splits/Tabs** | Nativo | Via tmux/zellij |
| **Startup** | ~50-100ms | ~20-50ms |
| **Maturidade** | Novo (ativo) | Maduro (estável) |

## Recomendações de Uso

### Use WezTerm se você:
- ✅ Quer tabs e splits nativos (sem tmux)
- ✅ Precisa de configuração programável (Lua)
- ✅ Gosta de recursos avançados integrados
- ✅ Valoriza funcionalidades sobre minimalismo

### Use Alacritty se você:
- ✅ Prioriza máxima velocidade e leveza
- ✅ Prefere simplicidade e minimalismo
- ✅ Já usa tmux/zellij para multiplexação
- ✅ Quer menor consumo de bateria

## Configuração Original
Baseada na configuração do PopOS com otimizações:
- [Configuração Original](https://github.com/waldirborbajr/dotfiles/blob/main/wezterm/.config/wezterm/wezterm.lua)

## Customização

O arquivo de configuração está em:
```
modules/apps/wezterm.nix
```

Para editar via WezTerm (se habilitado):
```bash
Ctrl+, (abre o editor na configuração)
```

## Keybindings Principais

| Atalho | Ação |
|--------|------|
| `Ctrl+Shift+C` | Copiar |
| `Ctrl+Shift+V` | Colar |
| `Ctrl+0` | Resetar tamanho da fonte |
| `Ctrl+=` | Aumentar fonte |
| `Ctrl+-` | Diminuir fonte |
| `F11` | Fullscreen |
| `Ctrl+Shift+N` | Nova janela |
| `Ctrl+Shift+O` | Toggle transparência |
| `Ctrl+Shift+E` | Toggle ligatures |
| `Ctrl+,` | Editar config |

## Troubleshooting

### WezTerm não inicia
```bash
# Verificar se está instalado
which wezterm

# Testar configuração
wezterm --config-file ~/.config/wezterm/wezterm.lua

# Ver logs
journalctl --user -u wezterm
```

### Fonte não aparece corretamente
```bash
# Listar fontes disponíveis
fc-list | grep -i "jetbrains"

# Verificar fontes Nerd instaladas
nix-shell -p nerdfonts --run "fc-list | grep Nerd"
```

### Performance ruim
Ajuste no `modules/apps/wezterm.nix`:
```lua
config.max_fps = 30  -- Reduzir se necessário
config.animation_fps = 15  -- Reduzir animações
```

## Migração do Alacritty

Se decidir migrar completamente:
1. Teste o WezTerm por alguns dias com ambos habilitados
2. Ajuste keybindings se necessário
3. Desabilite o Alacritty quando estiver confortável
4. Mantenha o módulo Alacritty para rollback fácil

```nix
# Fase de teste (ambos habilitados)
apps.alacritty.enable = true;
apps.wezterm.enable = true;

# Após decidir migrar
apps.alacritty.enable = false;
apps.wezterm.enable = true;
```

## Notas
- WezTerm usa mais memória que Alacritty (~50-100MB vs ~20-40MB)
- Startup é ligeiramente mais lento (~2-3x)
- GPU aceleração pode consumir mais bateria
- Configuração está otimizada para 60 FPS (balanço bateria/performance)
