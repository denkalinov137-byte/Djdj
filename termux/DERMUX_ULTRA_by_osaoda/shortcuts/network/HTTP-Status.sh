#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — NETWORK / HTTP Status
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget httpstatus
printf '\nPress Enter to return… '
read -r _dermux_pause || true
