#!/usr/bin/env bash
set -u

LOGFILE="troubleshooting.log"
: > "$LOGFILE"

ts() { date '+%Y-%m-%d %H:%M:%S'; }

run() {
  echo "→ $*" | tee -a "$LOGFILE"
  echo "──────────────────────────────────────────────" | tee -a "$LOGFILE"
  # shellcheck disable=SC2068
  "$@" 2>&1 | tee -a "$LOGFILE"
  echo "" | tee -a "$LOGFILE"
}

run_sh() {
  # executa via bash -c preservando pipes/redirect
  local cmd="$1"
  echo "→ bash -c: $cmd" | tee -a "$LOGFILE"
  echo "──────────────────────────────────────────────" | tee -a "$LOGFILE"
  bash -c "$cmd" 2>&1 | tee -a "$LOGFILE"
  echo "" | tee -a "$LOGFILE"
}

echo "=================================================================" | tee -a "$LOGFILE"
echo "          Troubleshooting - $(ts)" | tee -a "$LOGFILE"
echo "=================================================================" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "Sessão atual e compositor" | tee -a "$LOGFILE"
echo "──────────────────────────" | tee -a "$LOGFILE"
run echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP-}"
run echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE-}"
run_sh 'loginctl show-session "${XDG_SESSION_ID-}" -p Type -p Desktop -p Name 2>/dev/null || true'

echo "CPU governor / frequência / throttling" | tee -a "$LOGFILE"
echo "──────────────────────────────────────" | tee -a "$LOGFILE"
run_sh 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || true'
run_sh 'grep -H . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | head || true'
run lscpu
run_sh 'command -v sensors >/dev/null && sensors || echo "(sensors not available)"'

echo "Memória / Swap / ZRAM" | tee -a "$LOGFILE"
echo "──────────────────────" | tee -a "$LOGFILE"
run free -h
run_sh 'swapon --show || true'
run_sh 'command -v zramctl >/dev/null && zramctl || true'

echo "PSI (pressure stall information)" | tee -a "$LOGFILE"
echo "─────────────────────────────────" | tee -a "$LOGFILE"
run_sh 'for f in /proc/pressure/cpu /proc/pressure/memory /proc/pressure/io; do echo "== $$f =="; cat $$f; echo; done 2>/dev/null || true'

echo "VM / IO wait (vmstat)" | tee -a "$LOGFILE"
echo "──────────────────────" | tee -a "$LOGFILE"
run_sh 'command -v vmstat >/dev/null && vmstat 1 10 || echo "(vmstat not available)"'

echo "Disco / FS" | tee -a "$LOGFILE"
echo "──────────" | tee -a "$LOGFILE"
run_sh 'lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS,MODEL,ROTA,DISC-GRAN,DISC-MAX | sed -n "1,120p"'
run_sh 'findmnt -no SOURCE,FSTYPE,OPTIONS / || true'
run_sh 'command -v iostat >/dev/null && iostat -xz 1 5 || echo "(iostat not available; install sysstat if needed)"'

echo "Top consumo CPU / RAM" | tee -a "$LOGFILE"
echo "──────────────────────" | tee -a "$LOGFILE"
run_sh 'ps -eo pid,ppid,comm,%cpu,%mem --sort=-%cpu | head -n 25'
run_sh 'ps -eo pid,ppid,comm,%cpu,%mem --sort=-%mem | head -n 25'
run_sh 'command -v top >/dev/null && top -b -n1 | head -n 80 || true'

echo "IO (iotop - apenas processos com atividade)" | tee -a "$LOGFILE"
echo "────────────────────────────────────────────" | tee -a "$LOGFILE"
run_sh 'command -v iotop >/dev/null && sudo iotop -oPbn 1 | head -n 60 || echo "(iotop not available or failed)"'

echo "Kernel logs (últimos eventos úteis)" | tee -a "$LOGFILE"
echo "───────────────────────────────────" | tee -a "$LOGFILE"
run_sh 'dmesg -T | tail -n 200 || true'
run_sh 'journalctl -b -p warning..alert --no-pager | tail -n 200 || true'

echo "systemd – análise geral" | tee -a "$LOGFILE"
echo "────────────────────────" | tee -a "$LOGFILE"
run systemd-analyze
run_sh 'systemd-analyze blame | head -n 60'
run_sh 'systemd-analyze critical-chain | sed -n "1,160p"'

echo "Serviços importantes (system)" | tee -a "$LOGFILE"
echo "─────────────────────────────" | tee -a "$LOGFILE"
run_sh 'systemctl is-active docker libvirtd k3s 2>/dev/null || true'
run_sh "systemctl --no-pager --type=service --state=running | egrep -i 'docker|containerd|libvirtd|qemu|k3s|flatpak|xdg-desktop-portal|gdm|gnome|sddm|lightdm' || true"

echo "Serviços importantes (user/session)" | tee -a "$LOGFILE"
echo "────────────────────────────────────" | tee -a "$LOGFILE"
run_sh 'systemctl --user list-jobs --no-pager || true'
run_sh 'systemctl --user status xdg-desktop-portal --no-pager 2>/dev/null | sed -n "1,140p" || true'
run_sh 'systemctl --user status xdg-desktop-portal-hyprland --no-pager 2>/dev/null | sed -n "1,140p" || true'

echo "" | tee -a "$LOGFILE"
echo "Fim do relatório - $(ts)" | tee -a "$LOGFILE"
echo "=================================================================" | tee -a "$LOGFILE"
echo "Relatório salvo em: $(pwd)/$LOGFILE"
