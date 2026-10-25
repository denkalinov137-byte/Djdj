#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — NETWORK / Ping Host
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget ping
printf '\nPress Enter to return… '
read -r _dermux_pause || true
