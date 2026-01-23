#!/usr/bin/env bash

# Define o arquivo de log
LOGFILE="troubleshooting.log"

# Limpa o log anterior (opcional - comente esta linha se quiser manter histórico)
> "$LOGFILE"

echo "=================================================================" | tee -a "$LOGFILE"
echo "          Troubleshooting - $(date '+%Y-%m-%d %H:%M:%S')"        | tee -a "$LOGFILE"
echo "=================================================================" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

# Função auxiliar para executar comando e gravar tanto na tela quanto no log
run() {
    echo "→ $*" | tee -a "$LOGFILE"
    echo "──────────────────────────────────────────────" | tee -a "$LOGFILE"
    # Executa o comando, redireciona stdout e stderr para tee
    "$@" 2>&1 | tee -a "$LOGFILE"
    echo "" | tee -a "$LOGFILE"
}

echo "Sessão atual e compositor" | tee -a "$LOGFILE"
echo "──────────────────────────" | tee -a "$LOGFILE"

run echo "XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP"
run echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE"
run loginctl show-session "$XDG_SESSION_ID" -p Type -p Desktop -p Name

echo "CPU governor / frequência / throttling" | tee -a "$LOGFILE"
echo "──────────────────────────────────────" | tee -a "$LOGFILE"

run cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || true
run bash -c 'grep -H . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | head'
run lscpu

echo "Top consumo CPU / RAM" | tee -a "$LOGFILE"
echo "──────────────────────" | tee -a "$LOGFILE"

run ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 20
run ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 20

echo "IO (iotop - apenas processos com atividade)" | tee -a "$LOGFILE"
echo "────────────────────────────────────────────" | tee -a "$LOGFILE"

# iotop precisa de sudo e pode demorar um pouco
run sudo iotop -oPbn 1 2>&1 | head -n 35 || echo "(iotop não conseguiu executar)"

echo "systemd – análise geral" | tee -a "$LOGFILE"
echo "────────────────────────" | tee -a "$LOGFILE"

run systemd-analyze
run systemd-analyze blame | head -n 30
run systemd-analyze critical-chain

echo "Serviços importantes" | tee -a "$LOGFILE"
echo "────────────────────" | tee -a "$LOGFILE"

run systemctl is-active docker libvirtd k3s 2>/dev/null || true
run bash -c "systemctl --no-pager --type=service --state=running | egrep -i 'docker|containerd|libvirtd|qemu|k3s|flatpak|xdg-desktop-portal|gdm|gnome|sddm|lightdm' || true"

echo "" | tee -a "$LOGFILE"
echo "Fim do relatório - $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOGFILE"
echo "=================================================================" | tee -a "$LOGFILE"

echo ""
echo "Relatório salvo em: $(pwd)/$LOGFILE"