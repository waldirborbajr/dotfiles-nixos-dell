# HomeLab Configuration Guide

## 🏠 Visão Geral

Este guia explica como ativar e gerenciar a configuração **HomeLab headless** do Dell, preservando a configuração Desktop original para testes seguros.

---

## 📁 Estrutura do HomeLab

```
/etc/nixos/
├── hosts/
│   ├── dell.nix              # ✅ Config Desktop original (preservada)
│   └── dell-homelab.nix      # 🆕 Config HomeLab headless
├── profiles/
│   ├── desktop.nix           # Desktop profile
│   └── homelab.nix           # 🆕 HomeLab profile (minimal)
├── examples/
│   ├── homelab-docker-compose.yml  # Stack Docker completa
│   └── homelab-Caddyfile          # Reverse proxy config
├── homelab-switch.sh         # 🆕 Script para ativar HomeLab
└── revert-to-desktop.sh      # 🆕 Script para reverter ao Desktop
```

---

## 🚀 Ativando o HomeLab

### Passo 1: Fazer Switch para HomeLab

```bash
cd /etc/nixos
sudo ./homelab-switch.sh
```

O script irá:
- ✅ Verificar a configuração
- ✅ Fazer rebuild do sistema
- ✅ Mostrar próximos passos

### Passo 2: Reiniciar

```bash
sudo reboot
```

### Passo 3: Configurar Tailscale (após boot)

```bash
# Conectar ao Tailscale
sudo tailscale up

# Verificar status
tailscale status
```

### Passo 4: Setup Docker Stack

```bash
# Criar diretório do HomeLab
mkdir -p ~/homelab
cd ~/homelab

# Copiar configurações
cp /etc/nixos/examples/homelab-docker-compose.yml docker-compose.yml
cp /etc/nixos/examples/homelab-Caddyfile Caddyfile

# Criar estrutura de diretórios para mídia
mkdir -p /mnt/media/{movies,tvshows,music}

# Iniciar a stack
docker-compose up -d

# Verificar status
docker-compose ps
```

---

## 🔄 Revertendo para Desktop

Se quiser voltar para a configuração Desktop com i3:

```bash
cd /etc/nixos
sudo ./revert-to-desktop.sh
sudo reboot
```

---

## 📊 Comparação: Desktop vs HomeLab

| Aspecto | Desktop (dell) | HomeLab (dell-homelab) |
|---------|----------------|------------------------|
| **Interface** | i3 WM + X11 | Headless (TTY only) |
| **RAM Idle** | ~800MB-1GB | ~100-150MB |
| **Boot Time** | ~25-30s | ~8-10s |
| **Docker** | Desabilitado | Habilitado + auto-prune |
| **Audio** | Habilitado | Desabilitado |
| **Bluetooth** | Habilitado | Desabilitado |
| **Uso** | Desktop diário | Server/HomeLab |

---

## 🐳 Serviços Docker Incluídos

| Serviço | Porta | URL | Descrição |
|---------|-------|-----|-----------|
| **Portainer** | 9000 | `http://dell-homelab:9000` | Gerenciamento Docker |
| **Heimdall** | 8080 | `http://dell-homelab:8080` | Dashboard |
| **Plex** | 32400 | `http://dell-homelab:32400/web` | Media Server |
| **Netdata** | 19999 | `http://dell-homelab:19999` | Monitoring |
| **Caddy** | 80/443 | `http://homelab.local` | Reverse Proxy |

---

## 🔧 Comandos Úteis

### Docker

```bash
# Ver logs da stack
docker-compose logs -f

# Reiniciar um serviço
docker-compose restart <service>

# Parar tudo
docker-compose down

# Atualizar imagens
docker-compose pull
docker-compose up -d

# Ver uso de recursos
docker stats
```

### Tailscale

```bash
# Status
tailscale status

# IP Tailscale
tailscale ip

# Desconectar
sudo tailscale down

# Reconectar
sudo tailscale up
```

### Sistema

```bash
# Ver logs do sistema
journalctl -xef

# Ver uso de recursos
htop
btop

# Ver espaço em disco
ncdu /

# Ver serviços Docker
systemctl status docker
```

---

## 🌐 Acesso Remoto via Tailscale

Do seu Macbook (ou qualquer dispositivo no Tailscale):

```bash
# SSH
ssh borba@dell-homelab

# Ou via IP Tailscale
ssh borba@100.x.x.x

# Docker remoto (via context)
docker context create homelab --docker "host=ssh://borba@dell-homelab"
docker context use homelab
docker ps  # Executa no Dell!

# VS Code Remote
code --remote ssh-remote+dell-homelab /home/borba
```

**URLs via Tailscale:**
- Portainer: `http://dell-homelab.tail-xxxxx.ts.net:9000`
- Heimdall: `http://dell-homelab.tail-xxxxx.ts.net:8080`
- Plex: `http://dell-homelab.tail-xxxxx.ts.net:32400/web`

---

## 🔒 Segurança

### Firewall (já configurado)

Portas abertas no HomeLab:
- `22` - SSH
- `80/443` - Caddy (HTTP/HTTPS)
- `8080` - Heimdall
- `9000` - Portainer
- `19999` - Netdata
- `32400` - Plex

### SSH (já hardened)

- ✅ PermitRootLogin: no
- ✅ PasswordAuthentication: no (key only)
- ✅ Acesso via Tailscale recomendado

---

## 📦 Adicionando Mais Serviços Docker

Edite `~/homelab/docker-compose.yml`:

```yaml
services:
  # Exemplo: Jellyfin (alternativa ao Plex)
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "8096:8096"
    volumes:
      - jellyfin_config:/config
      - /mnt/media:/media
    networks:
      - homelab

volumes:
  jellyfin_config:
```

Depois:
```bash
docker-compose up -d
```

---

## 🐛 Troubleshooting

### Docker não inicia

```bash
# Ver status
systemctl status docker

# Restart
sudo systemctl restart docker

# Logs
journalctl -u docker -f
```

### Container não inicia

```bash
# Ver logs
docker-compose logs <service>

# Recrear
docker-compose up -d --force-recreate <service>
```

### Sem acesso à GUI

Na configuração HomeLab, não há GUI. Para emergências:

```bash
# TTY auto-login habilitado
# Conecte monitor e teclado
# Login automático como 'borba' no TTY1

# Ou acesse via SSH
ssh borba@dell-homelab
```

### Rollback completo

```bash
# Voltar para Desktop
cd /etc/nixos
sudo ./revert-to-desktop.sh
sudo reboot
```

---

## 📚 Recursos Adicionais

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Tailscale Docs](https://tailscale.com/kb/)
- [Portainer Docs](https://docs.portainer.io/)
- [Plex Docs](https://support.plex.tv/)

---

## ✅ Checklist de Setup Inicial

- [ ] Executar `./homelab-switch.sh`
- [ ] Reiniciar sistema
- [ ] Configurar Tailscale (`sudo tailscale up`)
- [ ] Criar diretório `~/homelab`
- [ ] Copiar docker-compose.yml e Caddyfile
- [ ] Criar estrutura de mídia em `/mnt/media`
- [ ] Iniciar stack: `docker-compose up -d`
- [ ] Acessar Portainer e configurar
- [ ] Acessar Heimdall e adicionar tiles
- [ ] Configurar Plex e adicionar bibliotecas
- [ ] Testar acesso via Tailscale remotamente
- [ ] Configurar backups (opcional)

---

## 🎯 Próximos Passos Recomendados

1. **Backup Automático**: Configure snapshots dos volumes Docker
2. **Watchtower**: Auto-update dos containers
3. **Monitoring**: Configure alertas no Netdata
4. **DNS Local**: Use Caddy para domínios locais
5. **SSL/TLS**: Configure certificados com Caddy

---

**Enjoy your HomeLab! 🏠🚀**
