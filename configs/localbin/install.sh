#!/bin/bash

# ----------------------
# Funções utilitárias
# ----------------------

# Verifica se comando existe
check_installed() { command -v "$1" &>/dev/null; }

# Obtém arquivo de configuração do shell (respeita $ZDOTDIR)
get_shell_config() {
  case "$(basename "$SHELL")" in
  bash) echo "$HOME/.bashrc" ;;
  zsh) echo "${ZDOTDIR:-$HOME}/.zshrc" ;;
  *) echo "" ;;
  esac
}

# Adiciona linha no shell config se não existir
add_to_shell_config() {
  local line="$1" desc="$2" cfg
  cfg="$(get_shell_config)"
  [ -z "$cfg" ] && echo "Shell não suportado. Configure $desc manualmente." && return
  grep -qF "$line" "$cfg" 2>/dev/null || {
    echo "Configurando $desc em $cfg..."
    echo -e "\n$line" >>"$cfg"
  }
}

# Verifica dependências básicas
check_system_requirements() {
  for cmd in cargo git nala fc-cache; do
    if ! check_installed $cmd; then
      case $cmd in
      cargo)
        echo "Instale Rust antes de continuar: https://www.rust-lang.org/tools/install"
        exit 1
        ;;
      git) sudo apt update && sudo apt install -y git ;;
      nala) sudo apt update && sudo apt install -y nala ;;
      fc-cache) sudo nala install -y fontconfig ;;
      esac
    fi
  done
  if ! check_installed go; then sh ./installgo.sh && echo "Reinicie o terminal para continuar." && exit 1; fi
}

# ----------------------
# Instalações principais
# ----------------------

# Instalar ferramentas via cargo
install_cargo_tools() {
  declare -A cargo_tools=(
    [fd]="fd-find" [rg]="ripgrep" [zoxide]="zoxide --locked"
    [bat]="bat" [eza]="eza" [yazi]="--force yazi-build"
    [cargo - install - update]="cargo-update" [starship]="starship --locked"
    [zellij]="zellij --locked" [atuin]="atuin" [cargo - seek]="cargo-seek"
  )
  for bin in "${!cargo_tools[@]}"; do
    check_installed "$bin" || cargo install ${cargo_tools[$bin]}
  done

  # fzf
  if ! check_installed fzf; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-update-rc
    add_to_shell_config '# fzf' "fzf"
  fi
}

# Instalar ferramentas Go
install_go_tools() {
  check_installed lazysql || go install github.com/jorgerojas26/lazysql@latest
  check_installed lazygit || go install github.com/jesseduffield/lazygit@latest
  check_installed lazydocker || go install github.com/jesseduffield/lazydocker@latest

  # libs Go extras
  for lib in \
    golang.org/x/tools/gopls \
    github.com/go-delve/delve/cmd/dlv \
    golang.org/x/tools/cmd/goimports \
    github.com/nametake/golangci-lint-langserver \
    github.com/Gelio/go-global-update@latest \
    github.com/golangci/golangci-lint/v2/cmd/golangci-lint; do
    go install "$lib@latest"
  done
}

# Instalar Helix via AppImage
install_helix_appimage() {
  if check_installed hx; then
    echo "Helix (hx) já instalado."
    return
  fi

  echo "Buscando última release do Helix..."
  LATEST=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  [ -z "$LATEST" ] && {
    echo "Não foi possível obter a versão do Helix."
    return 1
  }

  ASSET="helix-${LATEST}-x86_64.AppImage"
  URL="https://github.com/helix-editor/helix/releases/download/${LATEST}/${ASSET}"
  DEST_DIR="$HOME/.local/bin"
  DEST_PATH="${DEST_DIR}/hx"

  echo "Baixando $ASSET..."
  mkdir -p "$DEST_DIR"
  curl -L "$URL" -o "$DEST_PATH" || {
    echo "Falha ao baixar Helix."
    return 1
  }
  chmod +x "$DEST_PATH"

  add_to_shell_config 'export PATH="$HOME/.local/bin:$PATH"' "PATH local"

  echo "Helix instalado em $DEST_PATH"
}

# Instalar fontes JetBrainsMono Nerd Font
install_fonts() {
  if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    mkdir -p "$HOME/.local/share/fonts"
    curl -sL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o /tmp/JetBrainsMono.zip
    unzip -o /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts" && rm /tmp/JetBrainsMono.zip
    fc-cache -fv
  fi
}

# Instalar e configurar carapace
setup_carapace() {
  check_installed carapace || {
    echo "deb [trusted=yes] https://apt.fury.io/rsteube/ /" | sudo tee /etc/apt/sources.list.d/fury.list
    sudo nala update && sudo nala install -y carapace-bin
  }
  add_to_shell_config 'source <(carapace _carapace $(basename $SHELL))' "carapace"
}

# Instalar e configurar zsh-autosuggestions (NOVO)
setup_zsh_autosuggestions() {
  if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo "zsh-autosuggestions é apenas para Zsh. Pulando instalação."
    return
  fi

  local ZSH_AUTOSUGGESTIONS_DIR="${ZDOTDIR:-$HOME}/.zsh/zsh-autosuggestions"
  if [ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
    echo "Clonando zsh-autosuggestions..."
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR" || {
      echo "Falha ao clonar zsh-autosuggestions."
      return 1
    }
  else
    echo "zsh-autosuggestions já está instalado em $ZSH_AUTOSUGGESTIONS_DIR."
  fi

  # Adicionar configuração ao .zshrc
  local config_lines=$(
    cat <<'EOF'
# zsh-autosuggestions
[[ -f ${ZDOTDIR:-$HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ${ZDOTDIR:-$HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(accept-line)
bindkey '^ ' autosuggest-accept
EOF
  )
  add_to_shell_config "$config_lines" "zsh-autosuggestions"
}

# ----------------------
# Execução
# ----------------------
check_system_requirements
install_cargo_tools
install_go_tools
install_helix_appimage
install_fonts
add_to_shell_config 'eval "$(starship init $(basename $SHELL))"' "starship"
# setup_carapace
setup_zsh_autosuggestions # NOVO: Chamar a função de instalação do zsh-autosuggestions

echo "✅ Todas as ferramentas foram instaladas e configuradas com sucesso!"
