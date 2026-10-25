#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — FILES / Count Lines
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget count
printf '\nPress Enter to return… '
read -r _dermux_pause || true
