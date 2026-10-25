#!/data/data/com.termux/files/usr/bin/bash
set -u
mkdir -p "$HOME/DERMUX/backups"
out="$HOME/DERMUX/backups/DERMUX-widget-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
tmp="$(mktemp -d "$HOME/DERMUX/.task-backup.XXXXXX")" || exit 1
mkdir -p "$tmp/home"
for f in .zshrc .bashrc .termux/colors.properties .termux/termux.properties .config/starship.toml .config/dermux .shortcuts; do [ -e "$HOME/$f" ] && mkdir -p "$tmp/home/$(dirname "$f")" && cp -a "$HOME/$f" "$tmp/home/$f" 2>/dev/null || true; done
if tar -czf "$out" -C "$tmp" home; then echo "Backup saved: $out"; else echo 'Backup failed.'; fi
rm -rf "$tmp"
