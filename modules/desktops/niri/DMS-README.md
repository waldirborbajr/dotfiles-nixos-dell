# DankMaterialShell Configuration for Niri

Este módulo configura o **DankMaterialShell (DMS)** para o compositor Wayland **Niri** com o tema **Catppuccin Mocha**.

## 🎨 O que é o DankMaterialShell?

DankMaterialShell é uma shell moderna e altamente personalizável para ambientes Wayland, oferecendo:

- 🎯 Barra superior com widgets modulares
- 🖥️ Gerenciamento avançado de workspaces
- 🎵 Player de mídia integrado com visualizador de áudio
- 🌡️ Monitoramento de sistema (CPU, RAM, temperatura)
- 🔔 Central de notificações
- ⚙️ Centro de controle para configurações rápidas
- 🎨 Suporte a temas (usando Catppuccin)

## 📦 Instalação

### Opção 1: Usando Nix Flake (Recomendado)

Se o DankMaterialShell estiver disponível como um pacote Nix:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dank-material-shell.url = "github:dank-os/dank-material-shell";
  };
}
```

### Opção 2: Compilação Manual

1. Clone o repositório do DankMaterialShell:
```bash
git clone https://github.com/dank-os/dank-material-shell.git
cd dank-material-shell
```

2. Siga as instruções de compilação do projeto

3. Instale o binário em `~/.local/bin/` ou `/usr/local/bin/`

## ⚙️ Configuração Atual

A configuração está localizada em:
- **Módulo Principal**: `modules/desktops/niri/dank-material-shell.nix`
- **Autostart**: `modules/desktops/niri/dms-autostart.nix`
- **Arquivo de config**: `~/.config/DankMaterialShell/config.json`

### Características Configuradas

#### 🎨 Tema
- **Tema**: Catppuccin Mocha
- **Corner Radius**: 12px
- **Transparência**: 95%
- **Gaps**: 8px
- **Bordas**: 2px com cor primária

#### 📊 Widgets da Barra Superior

**Esquerda:**
- 🚀 Botão de lançador de aplicativos
- 🗂️ Seletor de workspaces
- 🪟 Janela em foco

**Centro:**
- 🕐 Relógio (formato 24h com segundos)
- ☀️ Clima

**Direita:**
- 🎵 Player de música com visualizador
- 📋 Área de transferência
- 💾 Uso de disco
- 🔥 Uso de CPU
- 🧠 Uso de memória
- 🔔 Notificações
- ⚙️ Centro de controle

#### 🎛️ Centro de Controle

Widgets disponíveis:
- 🔊 Controle de volume
- ☀️ Controle de brilho
- 📶 Wi-Fi
- 📞 Bluetooth
- 🔈 Saída de áudio
- 🎤 Entrada de áudio
- 🌙 Modo noturno
- 🌓 Modo escuro/claro

#### ⚡ Gerenciamento de Energia

**No AC (Plugado):**
- Desligar monitor: 15 min
- Bloquear tela: 30 min
- Perfil: Performance

**Na Bateria:**
- Desligar monitor: 5 min
- Bloquear tela: 10 min
- Suspender: 30 min
- Perfil: Power Saver
- Limite de carga: 80%

#### 🔔 Notificações

- Timeout baixa prioridade: 3s
- Timeout normal: 5s
- Timeout crítico: Sem timeout
- Histórico: Até 100 notificações (7 dias)
- Posição: Topo direito

#### 🎨 Fontes

- **Principal**: JetBrainsMono Nerd Font (peso 600, escala 1.15)
- **Monoespaçada**: JetBrainsMono Nerd Font Mono

## 🔧 Personalização

### Alterar Tema

Edite o arquivo de configuração em `~/.config/DankMaterialShell/config.json`:

```json
{
  "currentThemeName": "catppuccin-mocha",
  "currentThemeCategory": "registry"
}
```

Temas disponíveis:
- `catppuccin-mocha` (padrão)
- `catppuccin-macchiato`
- `catppuccin-frappe`
- `catppuccin-latte`

### Adicionar/Remover Widgets

No arquivo de configuração, modifique as seções `leftWidgets`, `centerWidgets` e `rightWidgets`:

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

### Ajustar Transparência

```json
{
  "popupTransparency": 0.95,
  "dockTransparency": 0.95,
  "transparency": 0.95
}
```

### Configurar Monitoramento de Sistema

Para habilitar o System Monitor widget:

```json
{
  "systemMonitorEnabled": true,
  "systemMonitorShowCpu": true,
  "systemMonitorShowMemory": true,
  "systemMonitorShowNetwork": true,
  "systemMonitorShowDisk": true
}
```

## 🔄 Integração com Niri

O DMS está configurado para trabalhar com o Niri através de:

1. **Variáveis de ambiente**:
   - `DMS_COMPOSITOR=niri`
   - `DMS_THEME=catppuccin-mocha`

2. **Configurações de layout**:
   - Gaps: 8px
   - Border radius: 12px
   - Border size: 2px

3. **Matugen templates**: Habilitados para sincronizar cores com:
   - GTK
   - Qt5/Qt6
   - Alacritty
   - Firefox
   - VSCode

## 🚀 Uso

### Atalhos Rápidos

Os atalhos do Niri continuam funcionando normalmente. Veja [keybindings.nix](keybindings.nix).

### Comandos do DMS

- **Abrir App Launcher**: `Mod+D` ou clique no botão launcher
- **Abrir Centro de Controle**: Clique no ícone de engrenagem
- **Abrir Notificações**: Clique no ícone de sino
- **Clipboard History**: Clique no ícone da área de transferência

### Gerenciamento de Workspaces

- **Scroll na barra**: Navegar entre workspaces
- **Clique no workspace**: Alternar para esse workspace
- **Arrastar janela**: Mover janela entre workspaces

## 🎨 Temas Customizados

Para criar um tema customizado:

1. Crie um arquivo em `~/.config/DankMaterialShell/themes/meu-tema/theme.json`:

```json
{
  "name": "Meu Tema",
  "colors": {
    "primary": "#cba6f7",
    "secondary": "#f5c2e7",
    "background": "#1e1e2e",
    "surface": "#313244",
    "text": "#cdd6f4"
  }
}
```

2. Altere a configuração:

```json
{
  "currentThemeName": "custom",
  "customThemeFile": "/home/seu-usuario/.config/DankMaterialShell/themes/meu-tema/theme.json"
}
```

## 🐛 Troubleshooting

### DMS não inicia

1. Verifique se o DMS está instalado:
```bash
which dank-material-shell
```

2. Verifique os logs:
```bash
journalctl --user -u dank-material-shell
```

3. Inicie manualmente para debug:
```bash
dank-material-shell --debug
```

### Widgets não aparecem

1. Verifique a configuração JSON
2. Certifique-se de que os serviços necessários estão rodando:
```bash
systemctl --user status pipewire wireplumber
```

### Tema não aplica

1. Limpe o cache:
```bash
rm -rf ~/.cache/DankMaterialShell
```

2. Reinicie o DMS:
```bash
pkill dank-material-shell
dms-start
```

## 📚 Recursos

- [Documentação Oficial do DMS](https://github.com/dank-os/dank-material-shell)
- [Niri Documentation](https://github.com/YaLTeR/niri)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)

## 🤝 Contribuindo

Se você fizer melhorias nesta configuração, considere:
1. Testar completamente
2. Documentar as mudanças
3. Compartilhar com a comunidade

## 📝 Notas

- Esta configuração mantém o Waybar como fallback
- O DMS e Waybar podem coexistir, mas apenas um deve estar ativo por vez
- Para desabilitar o DMS, edite `dank-material-shell.nix` e defina `isMacbook = false`
- Para voltar ao Waybar, desabilite o autostart do DMS

## 🔄 Atualizações

Para atualizar esta configuração:

```bash
# Rebuild do sistema
sudo nixos-rebuild switch --flake .#macbook

# Ou apenas home-manager
home-manager switch --flake .#borba@macbook-nixos
```

---

**Configuração criada com ❤️ usando NixOS e Catppuccin**
