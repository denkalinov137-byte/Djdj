#!/data/data/com.termux/files/usr/bin/bash
set -u
mkdir -p "$HOME/DERMUX/logs"
out="$HOME/DERMUX/logs/battery-log.txt"
if command -v termux-battery-status >/dev/null 2>&1; then printf '[%s] ' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$out"; termux-battery-status 2>/dev/null | jq -c . >> "$out" 2>/dev/null || echo 'Battery API failed' >> "$out"; command -v termux-notification >/dev/null 2>&1 && termux-notification --title 'DERMUX battery' --content 'Battery snapshot saved.' >/dev/null 2>&1 || true; else echo 'Termux:API app and termux-api package required.'; fi
