#!/usr/bin/env bash

OUTPUT="output.txt"

# limpa o arquivo de saída
: > "$OUTPUT"

# encontra todos os arquivos, aplicando filtros
find . -type f \
  ! -name ".*" \
  ! -name "*.sh" \
  ! -name "Makefile" \
  ! -name "Makefile" \
  ! -name "flake.lock" \
  ! -name "LICENSE" \
  ! -name "*.md" \
  ! -name "*.bak" \
  ! -path "./.git/*" \
| sort \
| while read -r file; do
    echo "----" >> "$OUTPUT"
    echo "${file#./}" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    cat "$file" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
done
