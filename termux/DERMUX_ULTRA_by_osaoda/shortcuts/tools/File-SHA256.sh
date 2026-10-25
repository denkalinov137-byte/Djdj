#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — TOOLS / File SHA256
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget hash
printf '\nPress Enter to return… '
read -r _dermux_pause || true
