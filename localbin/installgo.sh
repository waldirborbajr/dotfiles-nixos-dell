#!/bin/sh

# Script para verificar, atualizar ou instalar o Go (Golang) no Linux AMD64
# Executar com privilégios de root (sudo) para instalação/desinstalação
# Assume instalação padrão em /usr/local/go

set -e  # Para parar em erro

# Função para obter a versão mais recente disponível
get_latest_filename() {
    curl -s https://go.dev/dl/ | grep -o 'go[0-9.]\+\.linux-amd64\.tar\.gz' | sort -V | tail -1
}

get_version_from_filename() {
    filename="$1"
    echo "$filename" | sed 's/go\(.*\)\.linux-amd64\.tar\.gz/\1/'
}

# Função para comparar versões (retorna true se v1 < v2)
version_lt() {
    v1="$1"
    v2="$2"
    # Converte para formato comparável: major*10000 + minor*100 + patch
    n1=$(echo "$v1" | awk -F. '{ printf "%d%02d%02d\n", $1, $2, ($3 ? $3 : 0) }')
    n2=$(echo "$v2" | awk -F. '{ printf "%d%02d%02d\n", $1, $2, ($3 ? $3 : 0) }')
    [ "$n1" -lt "$n2" ]
}

# Função para identificar o shell atual e configurar o PATH
configure_path() {
    go_path="/usr/local/go/bin"
    shell_name=$(basename "$SHELL")
    config_file=""
    path_export=""

    # Verifica se o PATH já contém /usr/local/go/bin
    case "$PATH" in
        *"$go_path"*) 
            echo "O diretório $go_path já está no PATH."
            return 0
            ;;
    esac

    echo "Configurando PATH para $go_path no shell $shell_name..."

    case "$shell_name" in
        bash)
            config_file="$HOME/.bashrc"
            path_export="export PATH=\"$go_path:\$PATH\""
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            path_export="export PATH=\"$go_path:\$PATH\""
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            path_export="set -gx PATH $go_path \$PATH"
            ;;
        *)
            echo "Shell não suportado: $shell_name. Adicione manualmente 'export PATH=\"/usr/local/go/bin:\$PATH\"' ao seu arquivo de configuração do shell."
            return 0
    esac

    # Cria o diretório do arquivo de configuração, se necessário
    if [ "$shell_name" = "fish" ]; then
        mkdir -p "$(dirname "$config_file")"
    fi

    # Verifica se o PATH já está configurado no arquivo
    if [ -f "$config_file" ] && grep "$go_path" "$config_file" >/dev/null 2>&1; then
        echo "O PATH para $go_path já está configurado em $config_file."
        return 0
    fi

    # Adiciona ao arquivo de configuração
    echo "$path_export" >> "$config_file"
    echo "Adicionado $go_path ao PATH em $config_file."

    # Aplica na sessão atual e faz reload do arquivo de configuração
    PATH="$go_path:$PATH"
    if [ "$shell_name" = "fish" ]; then
        if command -v fish >/dev/null 2>&1; then
            fish -c "source $config_file" 2>/dev/null || echo "Aviso: Não foi possível recarregar $config_file na sessão atual do fish."
        else
            echo "Aviso: Fish não encontrado. Execute 'source $config_file' manualmente."
        fi
    else
        if [ -f "$config_file" ]; then
            $SHELL -c "source $config_file" 2>/dev/null || echo "Aviso: Não foi possível recarregar $config_file na sessão atual."
        else
            echo "Aviso: Arquivo $config_file não encontrado. Execute 'source $config_file' manualmente após criá-lo."
        fi
    fi
}

# Verifica versão instalada
if command -v go >/dev/null 2>&1; then
    installed_version=$(go version | cut -d' ' -f3 | sed 's/go//')
    echo "Go instalado: versão $installed_version"
else
    installed_version="0.0.0"
    echo "Go não está instalado."
fi

# Obtém a versão mais recente
latest_filename=$(get_latest_filename)
if [ -z "$latest_filename" ]; then
    echo "Erro: Não foi possível obter a versão mais recente do Go."
    exit 1
fi
latest_version=$(get_version_from_filename "$latest_filename")
download_url="https://go.dev/dl/$latest_filename"
echo "Versão mais recente disponível: $latest_version"

# Verifica se precisa atualizar ou instalar
if [ "$installed_version" = "$latest_version" ]; then
    echo "Go está atualizado: versão $installed_version"
    configure_path  # Configura o PATH mesmo se não atualizar, caso ainda não esteja configurado
elif version_lt "$installed_version" "$latest_version"; then
    echo "Atualizando/instalando Go $latest_version..."
    
    # Desinstala versão antiga se existir
    if [ "$installed_version" != "0.0.0" ]; then
        echo "Desinstalando versão antiga..."
        sudo rm -rf /usr/local/go
    fi
    
    # Baixa o arquivo
    echo "Baixando $download_url..."
    curl -L -o "/tmp/$latest_filename" "$download_url"
    
    # Instala
    echo "Instalando em /usr/local/go..."
    sudo tar -C /usr/local -xzf "/tmp/$latest_filename"
    rm "/tmp/$latest_filename"
    
    # Atualiza o PATH antes de verificar a nova versão
    PATH="/usr/local/go/bin:$PATH"
    
    # Verifica instalação
    if command -v go >/dev/null 2>&1; then
        new_version=$(go version | cut -d' ' -f3 | sed 's/go//')
        echo "Instalação concluída! Nova versão: $new_version"
        configure_path  # Configura o PATH após a instalação
    else
        echo "Erro na instalação."
        exit 1
    fi
else
    echo "Versão instalada ($installed_version) é mais recente que a disponível ($latest_version)."
    configure_path  # Configura o PATH mesmo se não atualizar, caso ainda não esteja configurado
fi
