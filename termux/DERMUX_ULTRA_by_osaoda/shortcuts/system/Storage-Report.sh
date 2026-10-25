#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — SYSTEM / Storage Report
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget storage
printf '\nPress Enter to return… '
read -r _dermux_pause || true
