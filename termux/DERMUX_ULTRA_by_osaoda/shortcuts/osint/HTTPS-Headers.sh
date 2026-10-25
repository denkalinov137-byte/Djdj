#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — OSINT / HTTPS Headers
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget headers
printf '\nPress Enter to return… '
read -r _dermux_pause || true
