#!/usr/bin/env bash
set -euo pipefail

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Instala/atualiza seus apps (coloque aqui sua lista atual, sem remover nada)
flatpak install -y --or-update flathub \
  com.brave.Browser \
  org.mozilla.firefox \
  md.obsidian.Obsidian \
  com.visualstudio.code \
  com.anydesk.Anydesk

# Opcional: só roda quando você quiser
flatpak uninstall -y --unused || true
flatpak update -y || true
