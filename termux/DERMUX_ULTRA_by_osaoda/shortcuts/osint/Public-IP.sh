#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — OSINT / Public IP
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget publicip
printf '\nPress Enter to return… '
read -r _dermux_pause || true
