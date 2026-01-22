#!/usr/bin/env bash

# Encontra todos .nix e processa um por um
find . -type f -name "*.nix" -print0 | while IFS= read -r -d '' arquivo; do
    # Remove o ./ do início
    caminho_relativo="${arquivo#./}"
    
    # Monta a linha esperada (exatamente como será inserida)
    linha_esperada="# ${caminho_relativo}"
    
    echo "Verificando: $arquivo"
    
    # Lê a primeira linha (se o arquivo não estiver vazio)
    if [ -s "$arquivo" ]; then
        primeira_linha=$(head -n 1 "$arquivo")
        
        # Remove espaços extras para comparação mais robusta (opcional, mas ajuda)
        primeira_linha_limpa="${primeira_linha#"${primeira_linha%%[![:space:]]*}"}"
        primeira_linha_limpa="${primeira_linha_limpa%"${primeira_linha_limpa##*[![:space:]]}"}"
        
        if [[ "$primeira_linha_limpa" == "# ${caminho_relativo}"* ]]; then
            echo "→ Já contém o cabeçalho esperado → pulando"
            echo ""
            continue
        fi
    else
        echo "→ Arquivo vazio → será processado"
    fi
    
    echo "→ Inserindo:"
    echo "   $linha_esperada"
    echo "   # ---"
    
    # Cria backup (só se for realmente modificar)
    cp "$arquivo" "$arquivo.bak"
    
    # Insere as duas linhas no topo (GNU sed)
    sed -i "1i # ---" "$arquivo"
    sed -i "1i ${linha_esperada}" "$arquivo"
    
    echo "Feito."
    echo ""
done

echo "Processamento concluído!"
echo "Arquivos originais preservados com extensão .bak (quando modificados)"

find . -type f -name "*.bak" -delete