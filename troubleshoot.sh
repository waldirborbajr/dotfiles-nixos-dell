#!/usr/bin/env bash
set -euo pipefail

LOGFILE="${LOGFILE:-troubleshooting.log}"
: > "$LOGFILE"

headline() {
  echo "=================================================================" | tee -a "$LOGFILE"
  echo "          Troubleshooting - $(date '+%Y-%m-%d %H:%M:%S')"        | tee -a "$LOGFILE"
  echo "=================================================================" | tee -a "$LOGFILE"
  echo "" | tee -a "$LOGFILE"
}

section() {
  echo "" | tee -a "$LOGFILE"
  echo "$1" | tee -a "$LOGFILE"
  echo "──────────────────────────────────────────────" | tee -a "$LOGFILE"
}

run() {
  echo "→ $*" | tee -a "$LOGFILE"
  echo "──────────────────────────────────────────────" | tee -a "$LOGFILE"
  bash -lc "$*" 2>&1 | tee -a "$LOGFILE" || true
  echo "" | tee -a "$LOGFILE"
}

headline

section "Basic identity"
run 'echo "Host: $(hostname)"; echo "Kernel: $(uname -r)"; echo "Uptime: $(uptime -p)"'
run 'echo "User: $(id)"; echo "Shell: $SHELL"; echo "PWD: $(pwd)"'

section "Session / compositor"
run 'echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP-}"; echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE-}"; echo "XDG_SESSION_ID=${XDG_SESSION_ID-}"'
run 'loginctl show-session "${XDG_SESSION_ID-}" -p Type -p Desktop -p Name 2>/dev/null || true'
run 'command -v hyprctl >/dev/null && hyprctl systeminfo || echo "(hyprctl not available)"'
run 'command -v hyprctl >/dev/null && hyprctl monitors || true'
run 'command -v hyprctl >/dev/null && hyprctl clients | head -n 120 || true'

section "CPU / frequency / throttling"
run 'lscpu'
run 'command -v cpupower >/dev/null && cpupower frequency-info || echo "(cpupower not installed)"'
run 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || true'
run 'grep -H . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | head -n 40 || true'
run 'grep -H . /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | head -n 40 || true'

section "Temps / sensors"
run 'command -v sensors >/dev/null && sensors || echo "(sensors not available; install lm_sensors)"'

section "Memory / swap / zram"
run 'free -h'
run 'swapon --show || true'
run 'command -v zramctl >/dev/null && zramctl || echo "(zramctl not available; install util-linux)"
'
run 'lsmod | grep -E "^zram" || true'
run 'for f in /sys/block/zram*/mm_stat /sys/block/zram*/disksize /sys/block/zram*/comp_algorithm; do [ -e "$f" ] && echo "== $f ==" && cat "$f"; done'

section "PSI (pressure stall information)"
run 'for f in /proc/pressure/cpu /proc/pressure/memory /proc/pressure/io; do echo "== $f =="; cat "$f"; echo; done 2>/dev/null || true'

section "VM / IO wait (vmstat)"
run 'command -v vmstat >/dev/null && vmstat 1 10 || echo "(vmstat not available; install procps)"'

section "Disk / filesystem"
run 'lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS,MODEL,ROTA,DISC-GRAN,DISC-MAX | sed -n "1,160p"'
run 'findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS / /boot 2>/dev/null || true'
run 'command -v iostat >/dev/null && iostat -xz 1 5 || echo "(iostat not available; install sysstat)"'
run 'command -v smartctl >/dev/null && sudo smartctl -H /dev/sda 2>/dev/null || echo "(smartctl not available or not /dev/sda; install smartmontools)"'

section "Open files limits (important if you saw 'Too many open files')"
run 'echo "ulimit -n=$(ulimit -n)"; cat /proc/sys/fs/file-max; cat /proc/sys/fs/file-nr'
run 'systemctl show NetworkManager -p LimitNOFILE 2>/dev/null || true'
run 'systemctl show docker -p LimitNOFILE 2>/dev/null || true'
run 'systemctl show libvirtd -p LimitNOFILE 2>/dev/null || true'
run 'systemctl show --user xdg-desktop-portal -p LimitNOFILE 2>/dev/null || true'
run 'sudo lsof -n 2>/dev/null | wc -l || echo "(lsof not available; install lsof)"'
run 'for pid in $(ps -e -o pid= | head -n 80); do c=$(ls /proc/$pid/fd 2>/dev/null | wc -l || true); echo "$c $pid"; done | sort -nr | head -n 20'

section "Top CPU / RAM"
run 'ps -eo pid,ppid,comm,%cpu,%mem --sort=-%cpu | head -n 30'
run 'ps -eo pid,ppid,comm,%cpu,%mem --sort=-%mem | head -n 30'
run 'command -v top >/dev/null && top -b -n1 | head -n 120 || true'

section "I/O per-process (optional tools)"
run 'command -v iotop >/dev/null && sudo iotop -oPbn 1 | head -n 80 || echo "(iotop not available or failed; install iotop)"'

section "systemd boot & critical chain"
run 'systemd-analyze'
run 'systemd-analyze blame | head -n 80'
run 'systemd-analyze critical-chain | sed -n "1,200p"'

section "Failed units (system + user)"
run 'systemctl --failed --no-pager || true'
run 'systemctl --user --failed --no-pager || true'

section "Important services status"
run 'systemctl is-active docker libvirtd k3s NetworkManager 2>/dev/null || true'
run 'systemctl --no-pager --type=service --state=running | egrep -i "docker|containerd|libvirtd|qemu|k3s|flatpak|xdg-desktop-portal|gdm|gnome|sddm|lightdm|NetworkManager" || true'
run 'systemctl --user --no-pager --type=service --state=running | egrep -i "xdg-desktop-portal|hyprland|waybar|mako|swayidle|pipewire|wireplumber" || true'

section "User services deep dive (portals + your xdg-config-links)"
run 'systemctl --user status xdg-desktop-portal --no-pager | sed -n "1,200p" || true'
run 'systemctl --user status xdg-desktop-portal-hyprland --no-pager | sed -n "1,200p" || true'
run 'systemctl --user status xdg-config-links --no-pager | sed -n "1,200p" || true'
run 'journalctl --user -u xdg-config-links --no-pager -n 200 || true'

section "Kernel logs (warnings/errors) - needs sudo for dmesg"
run 'sudo dmesg -T | tail -n 200'
run 'journalctl -b -p warning..alert --no-pager | tail -n 250 || true'

section "Network quick view"
run 'ip -br link'
run 'ip -br addr'
run 'nmcli general status 2>/dev/null || true'
run 'nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status 2>/dev/null || true'

section "Done"
echo "Fim do relatório - $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOGFILE"
echo "=================================================================" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"
echo "Relatório salvo em: $(pwd)/$LOGFILE"
