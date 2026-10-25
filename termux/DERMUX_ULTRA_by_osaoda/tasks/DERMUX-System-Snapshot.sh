#!/data/data/com.termux/files/usr/bin/bash
set -u
mkdir -p "$HOME/DERMUX/logs"
out="$HOME/DERMUX/logs/system-$(date +%Y%m%d-%H%M%S).txt"
{ echo 'DERMUX ULTRA / LOCAL SNAPSHOT'; date '+%Y-%m-%d %H:%M:%S %z'; echo "Device: $(getprop ro.product.model 2>/dev/null || echo Android)"; echo; echo '[Memory]'; awk '/MemTotal|MemAvailable/ {printf "%s: %.0f MB\\n",$1,$2/1024}' /proc/meminfo 2>/dev/null; echo; echo '[Storage]'; df -h "$HOME" 2>/dev/null; echo; echo '[Local IPv4]'; ip -o -4 addr show scope global 2>/dev/null | awk '{print $2, $4}'; echo; echo '[Battery]'; termux-battery-status 2>/dev/null | jq . 2>/dev/null || echo 'Termux:API unavailable'; } > "$out"
command -v termux-notification >/dev/null 2>&1 && termux-notification --title 'DERMUX snapshot' --content "Saved: ${out##*/}" >/dev/null 2>&1 || true
