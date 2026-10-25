#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — OSINT / RDAP Domain
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget rdap
printf '\nPress Enter to return… '
read -r _dermux_pause || true
