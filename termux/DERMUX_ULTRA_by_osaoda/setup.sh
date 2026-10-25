#!/data/data/com.termux/files/usr/bin/bash
# DERMUX // BY @osaoda — terminal environment + widget shortcuts; no root required.
set -u
if [ -z "${PREFIX:-}" ] || [ ! -d "${PREFIX:-/nonexistent}" ] || ! command -v pkg >/dev/null 2>&1; then
  printf '\033[1;31mERROR:\033[0m Run this script inside the Termux Android app.\n'; exit 1
fi
BUNDLE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
C='\033[38;5;51m'; G='\033[38;5;48m'; Y='\033[38;5;220m'; R='\033[0m'
info(){ printf '%b[DERMUX]%b %s\n' "$C" "$R" "$*"; }
note(){ printf '%b[NOTE]%b %s\n' "$Y" "$R" "$*"; }
backup(){ local f="$1"; if [ -f "$f" ]; then cp -p "$f" "$f.dermux-backup-$STAMP" && info "Backup: $f.dermux-backup-$STAMP"; fi; }
clear 2>/dev/null || true
printf '%b' "$C"
cat <<'LOGO'
  ██████╗ ███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
  ██╔══██╗██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
  ██║  ██║█████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝
  ██║  ██║██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗
  ██████╔╝███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
                   B Y  @ O S A O D A
LOGO
printf '%b\n' "$R"
printf '  %bANDROID COMMAND DECK · PASSIVE OSINT · HOME SHORTCUTS%b\n\n' "$G" "$R"
echo 'Active package sources (review these before installing software):'
found=0
for f in "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.d"/*.list "$PREFIX/etc/apt/sources.list.d"/*.sources; do
  [ -f "$f" ] || continue
  if grep -Eq '^[[:space:]]*(deb[[:space:]]|URIs:|Types:)' "$f"; then printf '\n-- %s --\n' "$f"; grep -E '^[[:space:]]*(deb[[:space:]]|URIs:|Suites:|Types:|Components:)' "$f" | head -n 60; found=1; fi
done
[ "$found" = 1 ] || echo 'Could not read source definitions from common paths.'
printf '\nContinue with package updates/installs from these sources? [y/N] '
read -r repo_ok || repo_ok=n
case "$repo_ok" in y|Y|yes|YES)
  pkg update -y || note 'Package index refresh was incomplete.'
  packages=(zsh starship git curl jq python openssh tmux htop whois dnsutils iproute2 traceroute figlet bat eza fzf less termux-api termux-tools nano coreutils procps findutils gawk openssl unzip tar)
  for p in "${packages[@]}"; do
    if dpkg -s "$p" >/dev/null 2>&1; then info "Already installed: $p"; else info "Installing $p…"; pkg install -y "$p" || note "Optional package unavailable: $p"; fi
  done
  ;;
  *) note 'Package changes skipped. Theme/shortcuts will still install; check repositories with repoaudit.' ;;
esac

mkdir -p "$HOME/.termux" "$HOME/.config" "$HOME/.config/dermux" "$HOME/.shortcuts" \
  "$HOME/.shortcuts/system" "$HOME/.shortcuts/osint" "$HOME/.shortcuts/tools" \
  "$HOME/.shortcuts/tasks" "$HOME/.shortcuts/icons" "$HOME/.termux/widget/dynamic_shortcuts" "$HOME/DERMUX"
for f in "$HOME/.termux/colors.properties" "$HOME/.termux/termux.properties" "$HOME/.config/starship.toml" "$HOME/.zshrc"; do backup "$f" || note "Could not back up $f"; done

# Replace only earlier bundle-managed shortcut names; preserve the user's own scripts.
for f in Dashboard.sh Battery.sh Wi-Fi.sh Network-Info.sh Local-Ports.sh Storage-Report.sh Processes.sh Quick-Note.sh Update-Packages.sh Widget-Doctor.sh Passive-OSINT.sh DNS-Lookup.sh HTTPS-Headers.sh TLS-Certificate.sh Public-IP.sh LAN-Discovery.sh File-SHA256.sh Command-Map.sh Command-Center.sh DERMUX.sh DERMUX-Storage-Report.sh; do
  rm -f "$HOME/.shortcuts/$f" "$HOME/.shortcuts/system/$f" "$HOME/.shortcuts/osint/$f" "$HOME/.shortcuts/tools/$f"
done
rm -f "$HOME/.shortcuts/HUD.sh" "$HOME/.shortcuts/OSINT-target.sh" "$HOME/.shortcuts/LAN-scan.sh" \
  "$HOME/.shortcuts/tasks/Core-Storage-Report.sh"

cat > "$HOME/.termux/colors.properties" <<'COLORS'
background=#060812
foreground=#e7f5ff
cursor=#66f5ff
color0=#060812
color1=#ff5470
color2=#64ffda
color3=#ffd479
color4=#70a5ff
color5=#c59bff
color6=#66f5ff
color7=#e7f5ff
color8=#273148
color9=#ff8498
color10=#91ffe8
color11=#ffe7a8
color12=#a4c5ff
color13=#d9b9ff
color14=#a2fbff
color15=#ffffff
COLORS
cat > "$HOME/.termux/termux.properties" <<'PROPS'
# DERMUX // BY @osaoda
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','ENTER']]
use-black-ui = true
PROPS
cat > "$HOME/.config/starship.toml" <<'STARSHIP'
add_newline = false
command_timeout = 1000
format = """
[╭─](bold #66f5ff)[ DERMUX ](bold #c59bff)[ @ ](bold #66f5ff)$username[@](bold #66f5ff)$hostname[ :: ](dimmed white)$directory$git_branch$git_status
[╰─](bold #66f5ff)$character"""
[username]
show_always = true
style_user = "bold #c59bff"
format = "[$user]($style)"
[hostname]
ssh_only = false
style = "bold #64ffda"
format = "[$hostname](bold #64ffda)"
[directory]
style = "bold #ffd479"
truncation_length = 3
truncate_to_repo = false
format = "[ $path]($style)"
[git_branch]
style = "bold #c59bff"
format = " [git:$branch](bold #c59bff)"
[git_status]
style = "bold #ffd479"
format = "([$all_status$ahead_behind]($style))"
[character]
success_symbol = "[❯](bold #64ffda) "
error_symbol = "[❯](bold #ff5470) "
[cmd_duration]
min_time = 2000
format = "[took $duration](dimmed white) "
[package]
disabled = true
STARSHIP

if [ ! -f "$BUNDLE_DIR/lib/dermux.sh" ]; then note 'Bundled library missing; cannot finish.'; exit 1; fi
cp "$BUNDLE_DIR/lib/dermux.sh" "$HOME/.config/dermux/dermux.sh"
chmod 600 "$HOME/.config/dermux/dermux.sh"

# Install categorized launcher scripts and root Command Center shortcut.
for cat in system network osint dev files tools; do
  mkdir -p "$HOME/.shortcuts/$cat"
  for f in "$BUNDLE_DIR/shortcuts/$cat"/*.sh; do [ -f "$f" ] || continue; cp "$f" "$HOME/.shortcuts/$cat/$(basename "$f")"; chmod 700 "$HOME/.shortcuts/$cat/$(basename "$f")"; done
done
cp "$BUNDLE_DIR/shortcuts/DERMUX.sh" "$HOME/.shortcuts/DERMUX.sh"; chmod 700 "$HOME/.shortcuts/DERMUX.sh"
cp "$BUNDLE_DIR/shortcuts/DERMUX-Storage-Report.sh" "$HOME/.shortcuts/tasks/DERMUX-Storage-Report.sh"; chmod 700 "$HOME/.shortcuts/tasks/DERMUX-Storage-Report.sh"
for task in "$BUNDLE_DIR/tasks"/*.sh; do [ -f "$task" ] || continue; cp "$task" "$HOME/.shortcuts/tasks/$(basename "$task")"; chmod 700 "$HOME/.shortcuts/tasks/$(basename "$task")"; done
for f in "$BUNDLE_DIR/assets/icons"/*.png; do [ -f "$f" ] || continue; cp "$f" "$HOME/.shortcuts/icons/$(basename "$f")"; done
# Dynamic Android launcher shortcuts are opt-in: user must press CREATE SHORTCUTS in Termux:Widget.
for f in "$BUNDLE_DIR/dynamic_shortcuts"/*; do [ -f "$f" ] || continue; cp "$f" "$HOME/.termux/widget/dynamic_shortcuts/$(basename "$f")"; chmod 700 "$HOME/.termux/widget/dynamic_shortcuts/$(basename "$f")"; done

# Correct permissions: plugin needs traverse/read permission on parent directories and executable scripts.
chmod 700 "$HOME/.shortcuts" "$HOME/.shortcuts/system" "$HOME/.shortcuts/osint" "$HOME/.shortcuts/tools" "$HOME/.shortcuts/network" "$HOME/.shortcuts/dev" "$HOME/.shortcuts/files" "$HOME/.shortcuts/tasks" "$HOME/.shortcuts/icons" "$HOME/.termux/widget" "$HOME/.termux/widget/dynamic_shortcuts"
find "$HOME/.shortcuts" -type f -name '*.sh' -exec chmod 700 {} \; 2>/dev/null || true
find "$HOME/.shortcuts/icons" -type f -name '*.png' -exec chmod 600 {} \; 2>/dev/null || true

# Replace prior generated Zsh setup; otherwise preserve custom user .zshrc and append a marked block.
ZSHRC="$HOME/.zshrc"
if [ ! -f "$ZSHRC" ] || grep -Eq '^# (OBSIDIAN // CORE shell config|NEON TERMUX|DERMUX // BY @osaoda shell config)' "$ZSHRC"; then
  cat > "$ZSHRC" <<'ZSHRC'
# DERMUX // BY @osaoda shell config
[[ -o interactive ]] || return
export EDITOR=nano VISUAL=nano PAGER='less -R' LESS='-R'
export HISTFILE="$HOME/.zsh_history" HISTSIZE=10000 SAVEHIST=10000
setopt autocd interactivecomments hist_ignore_dups share_history extended_history
source "$HOME/.config/dermux/dermux.sh"
[[ -x "$PREFIX/bin/eza" ]] && { alias ls='eza --icons=never --group-directories-first'; alias ll='eza -lah --icons=never --group-directories-first'; alias tree='eza --tree --icons=never'; }
[[ -x "$PREFIX/bin/bat" ]] && alias cat='bat --plain --paging=never'
alias c='clear' e='dermux' ..='cd ..' ...='cd ../..' sysinfo='dermux_dashboard' dashboard='dermux_dashboard' menu='dermux_menu' netinfo='dermux_netinfo' ports='dermux_localports' update='dermux_update' widgetdoctor='dermux_widgetdoctor' battery='dermux_battery' wifi='dermux_wifi' storage='dermux_storage' osint='dermux_osint' tls='dermux_tls' headers='dermux_headers'
dermux(){ dermux_menu; }; core(){ dermux_menu; }; live(){ dermux_live; }; memory(){ dermux_memory; }; uptimeinfo(){ dermux_uptime; }; apps(){ dermux_apps; }; pinghost(){ dermux_ping "$@"; }; tracehost(){ dermux_trace "$@"; }; httpstatus(){ dermux_httpstatus "$@"; }; whoisdomain(){ dermux_whois "$@"; }; rdap(){ dermux_rdap "$@"; }; ctlookup(){ dermux_ct "$@"; }; robots(){ dermux_robots "$@"; }; repoaudit(){ dermux_repoaudit; }; healthcheck(){ dermux_healthcheck; }; matrix(){ dermux_matrix; }; jsonpretty(){ dermux_jsonpretty; }; urlencode(){ dermux_urlencode; }; urldecode(){ dermux_urldecode; }; b64encode(){ dermux_b64encode; }; b64decode(){ dermux_b64decode; }; calc(){ dermux_calc; }; gitstatus(){ dermux_gitstatus; }; findfile(){ dermux_findfile; }; countlines(){ dermux_countlines; }; archiveinfo(){ dermux_archiveinfo; }; backup(){ dermux_widget backup; }; updatepackages(){ dermux_update; }
help(){ dermux_help; }; dns(){ dermux_dns "$@"; }; publicip(){ dermux_publicip; }; landiscovery(){ dermux_lan_discovery; }
if [[ "${DERMUX_AUTO_DASH:-1}" == "1" ]]; then dermux_dashboard; fi
if command -v starship >/dev/null 2>&1; then eval "$(starship init zsh)"; fi
ZSHRC
else
  if ! grep -q 'DERMUX // BY @osaoda shell integration' "$ZSHRC"; then
    cat >> "$ZSHRC" <<'ZSHBLOCK'

# >>> DERMUX // BY @osaoda shell integration >>>
[[ -o interactive ]] || return
source "$HOME/.config/dermux/dermux.sh"
alias e='dermux' c='clear' dashboard='dermux_dashboard' sysinfo='dermux_dashboard' netinfo='dermux_netinfo' ports='dermux_localports' widgetdoctor='dermux_widgetdoctor' battery='dermux_battery' wifi='dermux_wifi' storage='dermux_storage' live='dermux_live' memory='dermux_memory' uptimeinfo='dermux_uptime' repoaudit='dermux_repoaudit' healthcheck='dermux_healthcheck'
help(){ dermux_help; }; dns(){ dermux_dns "$@"; }; osint(){ dermux_osint "$@"; }; tls(){ dermux_tls "$@"; }; headers(){ dermux_headers "$@"; }; publicip(){ dermux_publicip; }; dermux(){ dermux_menu; }; core(){ dermux_menu; }; apps(){ dermux_apps; }; pinghost(){ dermux_ping "$@"; }; tracehost(){ dermux_trace "$@"; }; httpstatus(){ dermux_httpstatus "$@"; }; whoisdomain(){ dermux_whois "$@"; }; rdap(){ dermux_rdap "$@"; }; ctlookup(){ dermux_ct "$@"; }; robots(){ dermux_robots "$@"; }; matrix(){ dermux_matrix; }; jsonpretty(){ dermux_jsonpretty; }; urlencode(){ dermux_urlencode; }; urldecode(){ dermux_urldecode; }; b64encode(){ dermux_b64encode; }; b64decode(){ dermux_b64decode; }; calc(){ dermux_calc; }; gitstatus(){ dermux_gitstatus; }; findfile(){ dermux_findfile; }; countlines(){ dermux_countlines; }; archiveinfo(){ dermux_archiveinfo; }; backup(){ dermux_widget backup; }; updatepackages(){ dermux_update; }
if command -v starship >/dev/null 2>&1; then eval "$(starship init zsh)"; fi
# <<< DERMUX // BY @osaoda shell integration <<<
ZSHBLOCK
  fi
fi

# Bash fallback for users who launch Bash manually or cannot set Zsh as the default.
BASHRC="$HOME/.bashrc"
backup "$BASHRC" || true
if [ ! -f "$BASHRC" ]; then : > "$BASHRC"; fi
if ! grep -q 'DERMUX // BY @osaoda Bash integration' "$BASHRC"; then
  cat >> "$BASHRC" <<'BASHBLOCK'

# DERMUX // BY @osaoda Bash integration
case $- in *i*)
  [ -r "$HOME/.config/dermux/dermux.sh" ] && source "$HOME/.config/dermux/dermux.sh"
  dermux(){ dermux_menu; }; core(){ dermux_menu; }; help(){ dermux_help; }
  dashboard(){ dermux_dashboard; }; live(){ dermux_live; }; battery(){ dermux_battery; }; wifi(){ dermux_wifi; }
  memory(){ dermux_memory; }; uptimeinfo(){ dermux_uptime; }; apps(){ dermux_apps; }; storage(){ dermux_storage; }
  netinfo(){ dermux_netinfo; }; ports(){ dermux_localports; }; processes(){ dermux_processes; }
  dns(){ dermux_dns "$@"; }; osint(){ dermux_osint "$@"; }; whoisdomain(){ dermux_whois "$@"; }
  rdap(){ dermux_rdap "$@"; }; ctlookup(){ dermux_ct "$@"; }; headers(){ dermux_headers "$@"; }
  tls(){ dermux_tls "$@"; }; robots(){ dermux_robots "$@"; }; publicip(){ dermux_publicip; }
  pinghost(){ dermux_ping "$@"; }; tracehost(){ dermux_trace "$@"; }; httpstatus(){ dermux_httpstatus "$@"; }
  hashfile(){ dermux_filehash; }; jsonpretty(){ dermux_jsonpretty; }; urlencode(){ dermux_urlencode; }; urldecode(){ dermux_urldecode; }
  b64encode(){ dermux_b64encode; }; b64decode(){ dermux_b64decode; }; calc(){ dermux_calc; }; gitstatus(){ dermux_gitstatus; }
  findfile(){ dermux_findfile; }; countlines(){ dermux_countlines; }; archiveinfo(){ dermux_archiveinfo; }
  backup(){ dermux_widget backup; }; repoaudit(){ dermux_repoaudit; }; healthcheck(){ dermux_healthcheck; }
  widgetdoctor(){ dermux_widgetdoctor; }; matrix(){ dermux_matrix; }; updatepackages(){ dermux_update; }
  alias e='dermux' c='clear' ll='ls -lah'
;; esac
BASHBLOCK
fi

if command -v chsh >/dev/null 2>&1 && command -v zsh >/dev/null 2>&1; then chsh -s zsh >/dev/null 2>&1 && info 'Zsh selected as default shell.' || note 'Could not set Zsh automatically; you can run zsh manually.'; fi
command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings >/dev/null 2>&1 || true
printf '\n%bRefreshing Termux:Widget list…%b\n' "$G" "$R"
if command -v am >/dev/null 2>&1; then am broadcast -n com.termux.widget/.TermuxWidgetProvider -a com.termux.widget.ACTION_REFRESH_WIDGET --ei appWidgetId 0 2>&1 | tail -n 5 || true; fi
if command -v pm >/dev/null 2>&1 && pm path com.termux.widget 2>/dev/null | grep -q '^package:'; then info 'Termux:Widget detected.'; else note 'Termux:Widget not detected by package manager; check the add-on and compatible app signatures.'; fi
printf '\n%b╔══════════════════════════════════════════════════════════╗%b\n' "$G" "$R"
printf '%b║               D E R M U X  //  @ O S A O D A            ║%b\n' "$G" "$R"
printf '%b║                    INSTALL COMPLETE                      ║%b\n' "$G" "$R"
printf '%b╚══════════════════════════════════════════════════════════╝%b\n\n' "$G" "$R"
printf 'Restart Termux. Try: dermux   help   widgetdoctor\n'
printf 'Widget fix: open Termux:Widget app → REFRESH. Then Home → Widgets → Termux:Widget.\n'
printf 'Dynamic shortcuts: Termux:Widget app → CREATE SHORTCUTS.\n'
printf 'No public IP lookup or external OSINT query runs automatically.\n'
