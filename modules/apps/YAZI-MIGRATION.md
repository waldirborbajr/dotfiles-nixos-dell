# Yazi Migration: Pop!_OS → NixOS

## ✅ Status da Migração

### Plugins Migrados

| Plugin | Pop!_OS (package.toml) | NixOS (yazi.nix) | Status |
|--------|------------------------|-------------------|--------|
| full-border | `yazi-rs/plugins:full-border` (rev: 57f1863) | `pkgs.yaziPlugins.full-border` | ✅ |
| git | `yazi-rs/plugins:git` (rev: 57f1863) | `pkgs.yaziPlugins.git` | ✅ |
| searchjump | `DreamMaoMao/searchjump` (rev: cab627c) | Custom fetchFromGitHub | ✅ |
| starship | `Rolv-Apneseth/starship` (rev: eca1861) | Custom fetchFromGitHub | ✅ |
| bookmarks | `dedukun/bookmarks` (rev: 9ef1254) | Custom fetchFromGitHub | ✅ |

### Tema (Flavor) Migrado

| Flavor | Pop!_OS | NixOS | Status |
|--------|---------|-------|--------|
| Catppuccin Macchiato | `yazi-rs/flavors:catppuccin-macchiato` (rev: 4a1802a) | Custom fetchFromGitHub | ✅ |

## 🔄 Mudanças de Workflow

### Pop!_OS (Imperativo)
```bash
# Instalar plugins
ya pkg add yazi-rs/plugins:git
ya pkg add DreamMaoMao/searchjump

# Atualizar plugins
ya pkg upgrade

# Remover plugins
ya pkg remove searchjump
```

### NixOS (Declarativo)
```bash
# 1. Editar configuração
nvim modules/apps/yazi.nix

# 2. Aplicar mudanças
just switch macbook

# 3. Atualizar tudo (incluindo plugins)
just upgrade macbook
```

## 🎯 Keybindings Preservados

### Plugins Adicionados
- **`s`** → searchjump (buscar e pular)
- **`'`** → Salvar bookmark
- **`"`** → Pular para bookmark
- **`bd`** → Deletar bookmark

### Keybindings Mantidos do Pop!_OS
Todos os seus keybindings originais foram preservados na configuração NixOS.

## 📦 Comparação de Arquivos

### Pop!_OS
```
~/.config/yazi/
├── yazi.toml          # Configuração manual
├── package.toml       # Lista de plugins (gerenciado por ya)
├── plugins/           # Instalados via ya pkg
│   ├── full-border.yazi/
│   ├── git.yazi/
│   ├── searchjump.yazi/
│   ├── starship.yazi/
│   └── bookmarks.yazi/
└── flavors/
    └── catppuccin-macchiato.yazi/
```

### NixOS
```
modules/apps/yazi.nix  # Única fonte de verdade
↓
~/.config/yazi/        # Gerado automaticamente
├── yazi.toml          # Gerado por home-manager
├── plugins/           # Symlinks para /nix/store
│   ├── full-border.yazi/ → /nix/store/xxx-yaziPlugins-full-border/
│   ├── git.yazi/         → /nix/store/xxx-yaziPlugins-git/
│   ├── searchjump.yazi/  → /nix/store/xxx-searchjump/
│   ├── starship.yazi/    → /nix/store/xxx-starship/
│   └── bookmarks.yazi/   → /nix/store/xxx-bookmarks/
└── flavors/
    └── catppuccin-macchiato.yazi/ → /nix/store/xxx-flavors/
```

## 🚫 Comandos que NÃO Precisa Mais

| Pop!_OS | NixOS | Motivo |
|---------|-------|--------|
| `ya pkg upgrade` | `just upgrade macbook` | Plugins gerenciados pelo Nix |
| `ya pkg add <plugin>` | Editar `yazi.nix` | Configuração declarativa |
| `ya pkg remove <plugin>` | Remover de `yazi.nix` | Configuração declarativa |
| Editar `package.toml` | Editar `yazi.nix` | Única fonte de verdade |

## 🎨 Tema Catppuccin

O tema Catppuccin Macchiato está configurado exatamente como no Pop!_OS:
- Flavor: catppuccin-macchiato
- Revision: 4a1802a (mesma do seu package.toml)

## 🔧 Futuras Atualizações

Para atualizar hashes quando novas versões forem lançadas:

```bash
# Para plugins customizados
nix-prefetch-github DreamMaoMao searchjump --rev <new-rev>
nix-prefetch-github Rolv-Apneseth starship.yazi --rev <new-rev>
nix-prefetch-github dedukun bookmarks.yazi --rev <new-rev>

# Atualizar hash em yazi.nix e rebuildar
just switch macbook
```

## ✅ Verificação

Para confirmar que tudo está igual:
```bash
# Ver plugins instalados
ls -la ~/.config/yazi/plugins/

# Ver tema
ls -la ~/.config/yazi/flavors/

# Testar yazi
yazi

# Keybindings customizados:
# - Pressione 's' para searchjump
# - Pressione ' para salvar bookmark
# - Pressione " para pular para bookmark
```

---

**Tudo migrado! Mesma funcionalidade, gerenciamento declarativo! 🎉**
