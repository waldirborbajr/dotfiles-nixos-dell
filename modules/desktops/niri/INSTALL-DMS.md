# 🚀 Guia de Instalação DankMaterialShell + Niri

## 📋 Resumo

Este guia mostra como usar o **DankMaterialShell (DMS)** com o compositor **Niri** no NixOS, com tema **Catppuccin Mocha**.

## ✅ O que foi configurado

### Arquivos Criados/Modificados:

1. **`dank-material-shell.nix`** - Configuração completa do DMS com Catppuccin
2. **`dms-autostart.nix`** - Script de inicialização automática
3. **`dms-scripts.nix`** - Scripts auxiliares de controle
4. **`dms-package.nix`** - Derivation para compilar o DMS (se necessário)
5. **`default.nix`** - Atualizado para importar os novos módulos
6. **`keybindings.nix`** - Adicionados atalhos do DMS

### Configuração JSON:

O arquivo de configuração está em `~/.config/DankMaterialShell/config.json` com:

- ✅ Tema: **Catppuccin Mocha**
- ✅ Transparência: **95%**
- ✅ Corner Radius: **12px**
- ✅ Gaps: **8px**
- ✅ Bordas: **2px**
- ✅ Fonte: **JetBrainsMono Nerd Font**
- ✅ Relógio 24h com segundos
- ✅ Widgets: CPU, RAM, Disco, Temperatura, Bateria
- ✅ Player de música com visualizador
- ✅ Centro de controle completo
- ✅ Gerenciamento de energia otimizado

## 🔧 Como Instalar

### Passo 1: Rebuild do Sistema

```bash
cd /workspaces/nixos-config

# Para rebuild completo do sistema
sudo nixos-rebuild switch --flake .#macbook

# OU apenas home-manager
home-manager switch --flake .#borba@macbook-nixos
```

### Passo 2: Instalar o DankMaterialShell

**IMPORTANTE:** O DankMaterialShell precisa ser instalado separadamente, pois pode não estar no nixpkgs.

#### Opções de Instalação:

**A) Via Repositório Oficial (quando disponível):**
```bash
# Adicionar ao flake.nix
{
  inputs = {
    dank-material-shell.url = "github:dank-os/dank-material-shell";
  };
}
```

**B) Compilação Manual:**
```bash
# Clone o repositório
git clone https://github.com/dank-os/dank-material-shell.git
cd dank-material-shell

# Compile e instale
nix build
nix profile install
```

**C) Via nix-env (temporário para testes):**
```bash
nix-env -iA nixpkgs.dank-material-shell
```

### Passo 3: Verificar Instalação

```bash
# Verificar se o binário está disponível
which dank-material-shell

# Testar manualmente
dank-material-shell --version
```

### Passo 4: Logout/Login

Faça logout e login novamente no Niri. O DMS deve iniciar automaticamente.

## ⌨️ Atalhos de Teclado

### Atalhos do DankMaterialShell:

| Atalho | Ação |
|--------|------|
| `Mod+Space` | Toggle App Launcher |
| `Mod+N` | Toggle Notificações |
| `Mod+,` (vírgula) | Toggle Centro de Controle |
| `Mod+V` | Toggle Histórico da Área de Transferência |

### Atalhos Originais do Niri (mantidos):

| Atalho | Ação |
|--------|------|
| `Mod+Return` | Abrir terminal (Alacritty) |
| `Mod+D` | Abrir launcher (Fuzzel) |
| `Mod+B` | Abrir navegador (Firefox) |
| `Mod+Q` | Fechar janela |
| `Mod+H/J/K/L` | Navegar entre janelas (Vim style) |
| `Mod+1-9` | Trocar workspace |
| `Mod+Shift+1-9` | Mover janela para workspace |

## 🛠️ Scripts Disponíveis

Após o rebuild, você terá acesso aos seguintes comandos:

```bash
# Controles do DMS
dms-toggle-launcher           # Abre/fecha o launcher
dms-toggle-notifications      # Abre/fecha notificações
dms-toggle-control-center     # Abre/fecha centro de controle
dms-toggle-clipboard          # Abre/fecha clipboard history

# Gerenciamento
dms-restart                   # Reinicia o DMS
dms-status                    # Mostra status do DMS
dms-apply-theme               # Aplica/muda tema

# Inicialização
dms-start                     # Inicia o DMS manualmente
```

## 🎨 Personalização

### Trocar Tema

```bash
# Usar o script interativo
dms-apply-theme

# Ou editar manualmente
vim ~/.config/DankMaterialShell/config.json
# Mude: "currentThemeName": "catppuccin-mocha"
```

Temas disponíveis:
- `catppuccin-mocha` (padrão - escuro)
- `catppuccin-macchiato` (escuro)
- `catppuccin-frappe` (escuro)
- `catppuccin-latte` (claro)

### Ajustar Transparência

Edite `~/.config/DankMaterialShell/config.json`:

```json
{
  "popupTransparency": 0.95,
  "dockTransparency": 0.95,
  "transparency": 0.95
}
```

Valores: `0.0` (invisível) a `1.0` (opaco)

### Habilitar/Desabilitar Widgets

No arquivo de configuração, encontre `barConfigs` e modifique:

```json
{
  "rightWidgets": [
    { "id": "cpuUsage", "enabled": true },
    { "id": "memUsage", "enabled": true },
    { "id": "diskUsage", "enabled": false }  // Desabilitar
  ]
}
```

## 🔍 Troubleshooting

### DMS não inicia

```bash
# Verificar se está instalado
which dank-material-shell

# Ver logs
journalctl --user -xeu dank-material-shell

# Tentar iniciar manualmente
dank-material-shell --debug
```

### Widgets não aparecem

```bash
# Verificar serviços necessários
systemctl --user status pipewire wireplumber

# Reiniciar DMS
dms-restart
```

### Tema não aplica

```bash
# Limpar cache
rm -rf ~/.cache/DankMaterialShell

# Recarregar config
dms-restart
```

### Conflito com Waybar

Se o Waybar e DMS estiverem rodando juntos:

```bash
# Desabilitar Waybar temporariamente
pkill waybar

# Ou desabilitar permanentemente no Niri config
# Comente a seção waybar.nix no default.nix
```

## 📊 Status do DMS

Para ver se tudo está funcionando:

```bash
dms-status
```

Saída esperada:
```
✓ DankMaterialShell is running
  PID: 12345
  Memory: 85.3 MB
  CPU: 2.1%
```

## 🔄 Atualizações

Para atualizar a configuração do DMS:

```bash
# Editar configuração
vim ~/.config/nixos-config/modules/desktops/niri/dank-material-shell.nix

# Rebuild
sudo nixos-rebuild switch --flake .#macbook

# Reiniciar DMS
dms-restart
```

## 📝 Configuração Atual

### Widgets da Barra (Topo):

**Esquerda:**
- 🚀 Launcher
- 🗂️ Workspaces
- 🪟 Janela Ativa

**Centro:**
- 🕐 Relógio
- ☀️ Clima

**Direita:**
- 🎵 Música
- 📋 Clipboard
- 💾 Disco
- 🔥 CPU
- 🧠 RAM
- 🔔 Notificações
- ⚙️ Controle

### Centro de Controle Inclui:

- 🔊 Volume
- ☀️ Brilho
- 📶 Wi-Fi
- 📞 Bluetooth
- 🔈 Saída/Entrada de Áudio
- 🌙 Modo Noturno
- 🌓 Tema Claro/Escuro

## 🎯 Recursos Habilitados

- ✅ Visualizador de áudio do player de música
- ✅ Histórico de área de transferência
- ✅ Monitoramento de sistema em tempo real
- ✅ Notificações com histórico (100 últimas, 7 dias)
- ✅ Gerenciamento de energia inteligente
- ✅ Indicadores de privacidade (mic, câmera, tela)
- ✅ Integração com Niri workspaces
- ✅ Tema Catppuccin sincronizado

## 🚫 Desabilitar DMS

Se quiser voltar apenas ao Niri + Waybar:

1. Edite `modules/desktops/niri/default.nix`:
```nix
imports = [
  # ./dank-material-shell.nix  # Comentar
  # ./dms-autostart.nix        # Comentar
  # ./dms-scripts.nix          # Comentar
  ./waybar.nix                 # Manter
  # ...
];
```

2. Rebuild:
```bash
sudo nixos-rebuild switch --flake .#macbook
```

3. Logout/Login

## 📚 Referências

- [Niri README](modules/desktops/niri/README.md)
- [DMS README Completo](modules/desktops/niri/DMS-README.md)
- [Catppuccin](https://github.com/catppuccin/catppuccin)

## ✨ Dicas

1. **Performance**: O DMS é leve, usando ~80-100MB RAM
2. **Bateria**: Configurado para economizar bateria automaticamente
3. **Temas**: Todos sincronizam com Catppuccin via Matugen
4. **Workspaces**: Use scroll na barra para navegar
5. **Clipboard**: Mantém histórico de 50 itens

## 🤝 Suporte

Se encontrar problemas:

1. Verifique os logs: `journalctl --user -xeu dank-material-shell`
2. Teste manualmente: `dank-material-shell --debug`
3. Verifique a config: `cat ~/.config/DankMaterialShell/config.json`
4. Consulte: `modules/desktops/niri/DMS-README.md`

---

**Configuração criada para NixOS + Niri + Catppuccin** 🎉
