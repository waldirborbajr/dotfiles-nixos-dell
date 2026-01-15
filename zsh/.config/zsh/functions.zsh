# ===========================================
# System Functions
# ===========================================

# Transformei em função (mais seguro e legível)
syshealth() {

  pkgfix

  echo "🧹 Cleaning system..."
  sudo rm -rf /var/lib/apt/lists/*
  sudo nala update && sudo nala upgrade -y
  sudo nala autoremove -y
  sudo nala autopurge -y
  sudo nala clean
  
  echo "📦 Updating Flatpaks..."
  flatpak update -y 2>/dev/null && flatpak uninstall --unused -y 2>/dev/null
  
  echo "📦 Updating Snaps..."
  sudo snap refresh 2>/dev/null
  
  echo "⚙️ Updating Rust..."
  rustup update 2>/dev/null

  echo "⚙️ Updating all GO binaries..."
  gup update

  echo "⚙️ Updating installed Rust executables..."
  cargo install-update -a
  
  echo "⚙️ Updating Yazi packages"
  ya pkg upgrade
  
  echo "🎉 System updated!"
}

pkgfix() {
  sudo nala install -f
  sudo dpkg --configure -a
}

dockerzap() {
  # 1. Parar todos os containers
  docker stop $(docker ps -aq)

  # 2. Remover todos os containers
  docker rm $(docker ps -aq)

  # 3. Remover todas as imagens
  docker rmi $(docker images -q)

  # 4. Remover todos os volumes
  docker volume prune -f

  # 5. Remover todas as redes não utilizadas
  docker network prune -f

  # 6. Limpeza completa do sistema
  docker system prune -a -f --volumes
}

dockernew() {
  # Parar o serviço Docker completamente
  sudo systemctl stop docker

  # Remover todos os arquivos do Docker (EXTREMO - vai apagar TUDO)
  sudo rm -rf /var/lib/docker/*

  # Reiniciar o Docker
  sudo systemctl start docker
}

# ===========================================
# Zellij & Tooling (KEEPING YOUR WORKFLOW)
# ===========================================

zl() { zellij list-sessions }
za() { zellij attach "$1" }
zs() { zellij -s "$1" }
zc() { rm -rf ~/.cache/zellij }

tmx() {
  if [[ -z "$TMUX" && -z "$SSH_CONNECTION" ]]; then
    # tmux attach || tmux new
    tmux attach -t default >/dev/null 2>&1 || tmux new -s default
  fi
} 
# } && export -f tmx

lzg() { command -v lazygit >/dev/null && lazygit }
lzq() { command -v lazysql >/dev/null && lazysql }
lzd() { command -v lazydocker >/dev/null && lazydocker }

# Atualiza nome da aba do Zellij dinamicamente
zellij_tab_name_update() {
  # CORREÇÃO: Verificar se ZELLIJ está definida antes de usar
  if [[ -n "${ZELLIJ:-}" ]]; then
    local tab_name=''
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      tab_name+=$(basename "$(git rev-parse --show-toplevel)")/
      tab_name+=$(git rev-parse --show-prefix)
      tab_name=${tab_name%/}
    else
      tab_name=$PWD
      if [[ $tab_name == $HOME ]]; then
        tab_name="~"
      else
        tab_name=${tab_name##*/}
      fi
    fi
    command nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
  fi
}

# CORREÇÃO: Só adicionar à chpwd_functions se estiver dentro do Zellij
if [[ -n "${ZELLIJ:-}" ]]; then
  zellij_tab_name_update
  chpwd_functions+=(zellij_tab_name_update)
fi

chirp_update() {
  # Base URL for CHIRP daily builds
  CHIRP_BASE_URL="https://archive.chirpmyradio.com/chirp_next/"

  # Current version (based on provided filename)
  CURRENT_VERSION="20251010"

  # Check if CHIRP is installed with pip
  if ! pip list 2>/dev/null | grep -q "chirp"; then
    echo "CHIRP is not installed. Installing chirp-$CURRENT_VERSION-py3-none-any.whl..."
    # Download the specified .whl file
    curl -s -o "chirp-$CURRENT_VERSION-py3-none-any.whl" "${CHIRP_BASE_URL}next-$CURRENT_VERSION/chirp-$CURRENT_VERSION-py3-none-any.whl"
    if [ $? -eq 0 ]; then
      echo "Downloaded chirp-$CURRENT_VERSION-py3-none-any.whl"
      # Install using pip
      pipx install --system-site-packages "chirp-$CURRENT_VERSION-py3-none-any.whl"
      if [ $? -eq 0 ]; then
        echo "Successfully installed chirp-$CURRENT_VERSION-py3-none-any.whl"
        # Clean up downloaded file
        rm -f "chirp-$CURRENT_VERSION-py3-none-any.whl"
      else
        echo "Error: Failed to install chirp-$CURRENT_VERSION-py3-none-any.whl"
        rm -f "chirp-$CURRENT_VERSION-py3-none-any.whl"
        return 1
      fi
    else
      echo "Error: Failed to download chirp-$CURRENT_VERSION-py3-none-any.whl"
      return 1
    fi
  else
    echo "CHIRP is already installed. Checking for updates..."
    
    # Try alternative method to get latest version
    LATEST_VERSION=$(curl -s "$CHIRP_BASE_URL" | grep -oE 'next-[0-9]{8}' | sed 's/next-//' | sort -nr | head -1)
    
    # Alternative method: check the directory listing more robustly
    if [ -z "$LATEST_VERSION" ]; then
      LATEST_VERSION=$(curl -s "$CHIRP_BASE_URL" | grep -oE '[0-9]{8}' | sort -nr | head -1)
    fi

    if [ -z "$LATEST_VERSION" ]; then
      echo "Error: Could not fetch latest CHIRP version. The website structure may have changed."
      echo "Please check manually at: $CHIRP_BASE_URL"
      return 1
    fi

    # Compare versions
    if [ "$LATEST_VERSION" -gt "$CURRENT_VERSION" ]; then
      echo "New version found: chirp-$LATEST_VERSION-py3-none-any.whl (current: chirp-$CURRENT_VERSION-py3-none-any.whl)"
      # Construct the URL for the latest .whl file
      LATEST_WHL_URL="${CHIRP_BASE_URL}next-${LATEST_VERSION}/chirp-${LATEST_VERSION}-py3-none-any.whl"
      LATEST_WHL="chirp-${LATEST_VERSION}-py3-none-any.whl"
      
      # Download the new .whl file
      curl -s -o "$LATEST_WHL" "$LATEST_WHL_URL"
      if [ $? -eq 0 ]; then
        echo "Downloaded $LATEST_WHL"
        # Upgrade using pip
        pipx install --upgrade --force-reinstall "$LATEST_WHL"
        if [ $? -eq 0 ]; then
          echo "Successfully updated to $LATEST_WHL"
          # Clean up downloaded file
          rm -f "$LATEST_WHL"
        else
          echo "Error: Failed to install $LATEST_WHL"
          rm -f "$LATEST_WHL"
          return 1
        fi
      else
        echo "Error: Failed to download $LATEST_WHL_URL"
        return 1
      fi
    else
      echo "No newer version available. Current version ($CURRENT_VERSION) is up to date."
    fi
  fi
}

update_go() {
    echo "🔍 Verificando instalação do Go..."
    
    # Verifica se o Go está instalado e pega a versão atual
    if command -v go >/dev/null 2>&1; then
        CURRENT_GO_VERSION=$(go version | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
        echo "✅ Go instalado - Versão: $CURRENT_GO_VERSION"
    else
        echo "❌ Go não está instalado"
        CURRENT_GO_VERSION=""
    fi

    # Busca a última versão disponível
    echo "📡 Buscando última versão do Go..."
    
    # Método alternativo sem pattern matching
    LATEST_GO_VERSION=$(curl -s --fail "https://go.dev/VERSION?m=text" | head -1 | sed 's/go//')
    
    # Se falhar, tenta método alternativo
    if [ -z "$LATEST_GO_VERSION" ] || [ "$LATEST_GO_VERSION" = "null" ]; then
        LATEST_GO_VERSION=$(curl -s https://go.dev/dl/ | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/go//')
    fi
    
    if [ -z "$LATEST_GO_VERSION" ]; then
        echo "❌ Erro: Não foi possível obter a versão mais recente"
        echo "💡 Dica: Verifique sua conexão com a internet"
        return 1
    fi
    
    echo "📦 Última versão disponível: $LATEST_GO_VERSION"

    # Se já tem a versão mais recente, só configura environment
    if [ "$CURRENT_GO_VERSION" = "$LATEST_GO_VERSION" ]; then
        echo "✅ Já está na versão mais recente"
        setup_go_environment
        return 0
    fi

    # Se não tem Go instalado ou versão é diferente, prossegue com instalação/atualização
    if [ -z "$CURRENT_GO_VERSION" ]; then
        echo "🚀 Instalando Go $LATEST_GO_VERSION..."
    else
        echo "🔄 Atualizando Go $CURRENT_GO_VERSION → $LATEST_GO_VERSION..."
    fi

    # Define arquivo e URL de download
    GO_ARCHIVE="go${LATEST_GO_VERSION}.linux-amd64.tar.gz"
    DOWNLOAD_URL="https://golang.org/dl/${GO_ARCHIVE}"

    # Download do Go
    echo "💾 Baixando $GO_ARCHIVE..."
    if ! curl -fL -o "/tmp/${GO_ARCHIVE}" "$DOWNLOAD_URL"; then
        echo "❌ Erro no download do Go"
        echo "💡 Tentando URL alternativa..."
        # Tenta URL alternativa
        DOWNLOAD_URL="https://dl.google.com/go/${GO_ARCHIVE}"
        if ! curl -fL -o "/tmp/${GO_ARCHIVE}" "$DOWNLOAD_URL"; then
            echo "❌ Falha no download"
            return 1
        fi
    fi

    # Remove instalação anterior se existir
    if [ -d "/usr/local/go" ]; then
        echo "🧹 Removendo instalação anterior..."
        sudo rm -rf /usr/local/go
    fi

    # Instala nova versão
    echo "⚙️ Instalando Go..."
    sudo tar -C /usr/local -xzf "/tmp/${GO_ARCHIVE}"

    # Configura environment
    setup_go_environment

    # Limpeza
    rm -f "/tmp/${GO_ARCHIVE}"
    
    # Verifica instalação
    if command -v go >/dev/null 2>&1; then
        NEW_VERSION=$(go version)
        echo "✅ $NEW_VERSION"
        echo "🎉 Go instalado/atualizado com sucesso!"
    else
        echo "⚠️  Go instalado mas pode precisar recarregar o terminal"
        echo "💡 Execute: source ~/.zshrc"
    fi
}

# Função auxiliar para configurar environment
setup_go_environment() {
    echo "⚙️ Configurando environment..."
    
    local profile_file="$HOME/.zshrc"
    
    # Remove configurações antigas do Go se existirem
    if [ -f "$profile_file" ]; then
        grep -v "export PATH.*/usr/local/go/bin" "$profile_file" > "${profile_file}.tmp" && mv "${profile_file}.tmp" "$profile_file"
        grep -v "export GOPATH=" "$profile_file" > "${profile_file}.tmp" && mv "${profile_file}.tmp" "$profile_file"
        grep -v "export PATH.*GOPATH/bin" "$profile_file" > "${profile_file}.tmp" && mv "${profile_file}.tmp" "$profile_file"
        grep -v "# Go environment" "$profile_file" > "${profile_file}.tmp" && mv "${profile_file}.tmp" "$profile_file"
    fi
    
    # Adiciona novas configurações
    echo '# Go environment' >> "$profile_file"
    echo 'export PATH="$PATH:/usr/local/go/bin"' >> "$profile_file"
    echo 'export GOPATH="$HOME/go"' >> "$profile_file"
    echo 'export PATH="$PATH:$GOPATH/bin"' >> "$profile_file"

    # Cria diretórios do workspace
    mkdir -p "$HOME/go/"{bin,src,pkg}
    
    # Atualiza PATH na sessão atual
    export PATH="$PATH:/usr/local/go/bin"
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"
    
    echo "✅ Environment configurado"
}

# Session manager that prefers Zellij but falls back to TMUX
session() {
    # Skip in SSH or if already in a terminal multiplexer
    if [[ -n "$SSH_CONNECTION" ]] || [[ -n "$TMUX" ]] || [[ -n "$ZELLIJ" ]]; then
        return 0
    fi
    
    # Try to attach to existing Zellij session
    if command -v zellij >/dev/null 2>&1; then
        if zellij list-sessions 2>/dev/null | grep -q .; then
            echo "Attaching to Zellij..."
            zellij attach "$(zellij list-sessions | head -1)"
        else
            echo "Starting new Zellij session..."
            zellij
        fi
    # Fallback to tmux if Zellij isn't available
    elif command -v tmux >/dev/null 2>&1; then
        if [[ -z "$TMUX" ]]; then
            tmux attach || tmux new
        fi
    else
        echo "No terminal multiplexer found (Zellij or TMUX)"
    fi
}
