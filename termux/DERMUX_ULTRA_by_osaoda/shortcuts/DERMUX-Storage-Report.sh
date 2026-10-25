#!/data/data/com.termux/files/usr/bin/bash
# DERMUX background storage summary
used="$(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " · " $5 " used"}')"
[ -n "$used" ] || used='Storage unavailable'
if command -v termux-notification >/dev/null 2>&1; then termux-notification --title 'DERMUX // @osaoda' --content "Storage: $used" --id 8421; else printf 'DERMUX — Storage: %s\n' "$used"; fi
