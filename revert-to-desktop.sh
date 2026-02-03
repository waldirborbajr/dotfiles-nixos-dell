#!/usr/bin/env bash
# revert-to-desktop.sh
# Script para reverter para a configuração Desktop original (dell)

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Revert to Desktop Configuration (dell)        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar se está rodando como root ou com sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Este script precisa ser executado com sudo${NC}"
    echo -e "${YELLOW}💡 Use: sudo ./revert-to-desktop.sh${NC}"
    exit 1
fi

# Verificar se está no diretório correto
if [ ! -f "flake.nix" ]; then
    echo -e "${RED}❌ flake.nix não encontrado${NC}"
    echo -e "${YELLOW}💡 Execute este script no diretório /etc/nixos${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Configuração atual:${NC}"
nixos-version 2>/dev/null || echo "NixOS"
echo ""

echo -e "${YELLOW}⚠️  ATENÇÃO: Você está revertendo para a configuração Desktop (dell)${NC}"
echo -e "${YELLOW}📋 Isso irá:${NC}"
echo -e "  • Habilitar i3 Window Manager"
echo -e "  • Habilitar áudio e bluetooth"
echo -e "  • Desabilitar Docker (se estava desabilitado)"
echo -e "  • Restaurar profile desktop completo"
echo ""

# Perguntar confirmação
read -p "$(echo -e ${YELLOW}Deseja continuar com a reversão? [y/N]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Operação cancelada${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🚀 Executando: nixos-rebuild switch --flake .#dell${NC}"
echo ""

# Executar o rebuild
if nixos-rebuild switch --flake .#dell; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ Reversão para Desktop concluída com sucesso!   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📋 Próximos passos:${NC}"
    echo -e "${YELLOW}1. Reinicie o sistema: ${NC}sudo reboot"
    echo -e "${YELLOW}2. Você terá i3 WM novamente após login${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ Erro durante a reversão!                       ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi
