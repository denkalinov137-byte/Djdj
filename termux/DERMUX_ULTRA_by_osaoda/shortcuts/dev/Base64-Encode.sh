#!/data/data/com.termux/files/usr/bin/bash
# DERMUX ULTRA // by @osaoda — DEV / Base64 Encode
source "$HOME/.config/dermux/dermux.sh" || exit 1
dermux_widget b64encode
printf '\nPress Enter to return… '
read -r _dermux_pause || true
