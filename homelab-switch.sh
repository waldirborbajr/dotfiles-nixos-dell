#!/usr/bin/env bash
# homelab-switch.sh
# Script para fazer switch para a configuração HomeLab

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     NixOS HomeLab Configuration Switcher          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar se está rodando como root ou com sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Este script precisa ser executado com sudo${NC}"
    echo -e "${YELLOW}💡 Use: sudo ./homelab-switch.sh${NC}"
    exit 1
fi

# Verificar se está no diretório correto
if [ ! -f "flake.nix" ]; then
    echo -e "${RED}❌ flake.nix não encontrado${NC}"
    echo -e "${YELLOW}💡 Execute este script no diretório /etc/nixos${NC}"
    exit 1
fi

# Verificar se o host dell-homelab existe no flake
if ! grep -q "dell-homelab" flake.nix; then
    echo -e "${RED}❌ Host 'dell-homelab' não encontrado no flake.nix${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Configuração atual:${NC}"
nixos-version 2>/dev/null || echo "NixOS"
echo ""

echo -e "${YELLOW}🔍 Verificando configuração dell-homelab...${NC}"
nix flake show --all-systems 2>/dev/null | grep -A2 "dell-homelab" || true
echo ""

echo -e "${BLUE}🏗️  Iniciando rebuild para HomeLab...${NC}"
echo -e "${YELLOW}⚙️  Host: dell-homelab${NC}"
echo -e "${YELLOW}⚙️  Profile: headless server${NC}"
echo ""

# Perguntar confirmação
read -p "$(echo -e ${YELLOW}Deseja continuar com o switch? [y/N]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Operação cancelada${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🚀 Executando: nixos-rebuild switch --flake .#dell-homelab${NC}"
echo ""

# Executar o rebuild
if nixos-rebuild switch --flake .#dell-homelab; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ Switch para HomeLab concluído com sucesso!     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📋 Próximos passos:${NC}"
    echo -e "${YELLOW}1. Reinicie o sistema: ${NC}sudo reboot"
    echo -e "${YELLOW}2. Após boot, configure Tailscale: ${NC}sudo tailscale up"
    echo -e "${YELLOW}3. Setup Docker stack em: ${NC}~/homelab/"
    echo -e "${YELLOW}4. Copie docker-compose.yml de: ${NC}examples/homelab-docker-compose.yml"
    echo -e "${YELLOW}5. Inicie os containers: ${NC}docker-compose up -d"
    echo ""
    echo -e "${BLUE}📊 Acesso aos serviços:${NC}"
    echo -e "${YELLOW}  • Portainer:  ${NC}http://dell-homelab:9000"
    echo -e "${YELLOW}  • Heimdall:   ${NC}http://dell-homelab:8080"
    echo -e "${YELLOW}  • Plex:       ${NC}http://dell-homelab:32400/web"
    echo -e "${YELLOW}  • Netdata:    ${NC}http://dell-homelab:19999"
    echo ""
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ Erro durante o switch!                         ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}💡 Dicas para debugging:${NC}"
    echo -e "  • Verifique os logs acima"
    echo -e "  • Execute: ${BLUE}nix flake check${NC}"
    echo -e "  • Verifique syntax: ${BLUE}nixos-rebuild build --flake .#dell-homelab${NC}"
    echo ""
    exit 1
fi
