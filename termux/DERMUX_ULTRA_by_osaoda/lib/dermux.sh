# DERMUX // BY @osaoda — shared Bash/Zsh helpers. No root required.
_DX_C='\033[38;5;51m'; _DX_G='\033[38;5;48m'; _DX_P='\033[38;5;141m'; _DX_Y='\033[38;5;220m'; _DX_R='\033[0m'
_dx_banner(){
  printf '\033[2J\033[H%b' "$_DX_C"
  cat <<'BANNER'
  ██████╗ ███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
  ██╔══██╗██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
  ██║  ██║█████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ 
  ██║  ██║██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ 
  ██████╔╝███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
                 B Y  @ O S A O D A
BANNER
  printf '%b\n' "$_DX_R"
}
_dx_rule(){ printf '%b╭─[%s]─────────────────────────────────────────────╮%b\n' "$_DX_C" "$1" "$_DX_R"; }
_dx_end(){ printf '%b╰──────────────────────────────────────────────────╯%b\n' "$_DX_C" "$_DX_R"; }
_dx_pause(){ printf '\n%bPress Enter to return…%b ' "$_DX_P" "$_DX_R"; read -r _dx_dummy; }
_dx_valid_domain(){
  local d="${1:-}"
  [[ "$d" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?\.?$ && "$d" != *..* && "$d" != *://* && "$d" != *'/'* && "$d" != *' '* ]]
}
_dx_prompt_domain(){
  local prompt="${1:-Domain (example.com)}"
  printf '%s: ' "$prompt"; read -r _dx_target
  _dx_target="${_dx_target#https://}"; _dx_target="${_dx_target#http://}"; _dx_target="${_dx_target%%/*}"; _dx_target="${_dx_target%%:*}"
  if ! _dx_valid_domain "$_dx_target"; then printf '%bInvalid domain. Enter a hostname such as example.com, not a URL or IP.%b\n' "$_DX_Y" "$_DX_R"; return 2; fi
  return 0
}

dermux_dashboard(){
  _dx_banner
  _dx_rule 'DEVICE COMMAND DECK'
  local model batt wifi lip ram disk up storage api_status
  model="$(getprop ro.product.model 2>/dev/null | head -n 1)"; [ -n "$model" ] || model='Android device'
  printf '%b│%b  TIME       %s\n' "$_DX_C" "$_DX_R" "$(date '+%H:%M:%S  ·  %d %b %Y' 2>/dev/null || echo n/a)"
  printf '%b│%b  DEVICE     %s\n' "$_DX_C" "$_DX_R" "$model"
  batt='Termux:API app required'
  if command -v termux-battery-status >/dev/null 2>&1; then batt="$(termux-battery-status 2>/dev/null | jq -r 'if .percentage != null then "\(.percentage)% · \(.status // "unknown")" else "unavailable" end' 2>/dev/null)"; [ -n "$batt" ] || batt='unavailable'; fi
  wifi='Termux:API / Android permission may be required'
  if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then wifi="$(termux-wifi-connectioninfo 2>/dev/null | jq -r 'if (.ssid // "") != "" and .ssid != "<unknown ssid>" then "\(.ssid) · \(.link_speed_mbps // "?") Mbps" else "not shared by Android" end' 2>/dev/null)"; [ -n "$wifi" ] || wifi='unavailable'; fi
  lip="$(ip -o -4 addr show scope global 2>/dev/null | awk 'NR==1 {print $4; exit}')"; [ -n "$lip" ] || lip='not available'
  ram="$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if (t>0 && a>0) printf "%.0f / %.0f MB", (t-a)/1024, t/1024; else print "n/a"}' /proc/meminfo 2>/dev/null)"
  disk="$(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " · " $5 " used"}')"
  up="$(uptime -p 2>/dev/null | sed 's/^up //')"
  printf '%b│%b  BATTERY    %s\n' "$_DX_C" "$_DX_R" "$batt"
  printf '%b│%b  WI-FI      %s\n' "$_DX_C" "$_DX_R" "$wifi"
  printf '%b│%b  LOCAL IP   %s\n' "$_DX_C" "$_DX_R" "${lip:-n/a}"
  printf '%b│%b  MEMORY     %s\n' "$_DX_C" "$_DX_R" "${ram:-n/a}"
  printf '%b│%b  STORAGE    %s\n' "$_DX_C" "$_DX_R" "${disk:-n/a}"
  printf '%b│%b  UPTIME     %s\n' "$_DX_C" "$_DX_R" "${up:-n/a}"
  _dx_end
  printf '\n%bNo public-IP request runs automatically.%b\n' "$_DX_G" "$_DX_R"
  printf 'Type %bdermux%b for the command center, %bhelp%b for shortcuts.\n' "$_DX_Y" "$_DX_R" "$_DX_Y" "$_DX_R"
}

dermux_netinfo(){
  _dx_banner; _dx_rule 'LOCAL NETWORK · READ ONLY'
  printf '%bIPv4 addresses%b\n' "$_DX_G" "$_DX_R"; ip -o -4 addr show scope global 2>/dev/null | awk '{print "  " $2 "  " $4}' || true
  printf '\n%bDefault route%b\n' "$_DX_G" "$_DX_R"; ip -4 route show default 2>/dev/null || echo '  No default route detected.'
  printf '\n%bListening sockets on this phone%b\n' "$_DX_G" "$_DX_R"; if command -v ss >/dev/null 2>&1; then ss -tuln 2>/dev/null | head -n 20; else echo '  ss unavailable'; fi
  _dx_end
}

dermux_battery(){
  _dx_banner; _dx_rule 'BATTERY STATUS'
  if command -v termux-battery-status >/dev/null 2>&1; then termux-battery-status 2>/dev/null | jq . 2>/dev/null || termux-battery-status; else echo 'Install the separate Termux:API Android app from the same source/signature as Termux.'; echo 'Then run: pkg install termux-api'; fi
  _dx_end
}

dermux_wifi(){
  _dx_banner; _dx_rule 'WI-FI STATUS'
  if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then termux-wifi-connectioninfo 2>/dev/null | jq . 2>/dev/null || termux-wifi-connectioninfo; else echo 'Install Termux:API Android app and the termux-api package.'; fi
  printf '\nAndroid may hide SSID details unless the required permissions/location settings allow access.\n'; _dx_end
}

dermux_storage(){
  _dx_banner; _dx_rule 'STORAGE REPORT'
  printf '%bFilesystem usage%b\n' "$_DX_G" "$_DX_R"; df -h "$HOME" 2>/dev/null
  printf '\n%bTermux home size%b\n' "$_DX_G" "$_DX_R"; du -sh "$HOME" 2>/dev/null || true
  printf '\n%bLargest top-level folders (best-effort)%b\n' "$_DX_G" "$_DX_R"; du -k -d 1 "$HOME" 2>/dev/null | sort -nr | head -n 8 | awk '{printf "  %s MB  %s\n", int($1/1024), $2}'
  _dx_end
}

dermux_dns(){
  local host type
  host="${1:-}"
  if [ -z "$host" ]; then _dx_prompt_domain 'DNS domain'; [ $? -eq 0 ] || return 2; host="$_dx_target"; fi
  if ! _dx_valid_domain "$host"; then echo 'Invalid domain.'; return 2; fi
  _dx_banner; _dx_rule "DNS LOOKUP · $host"
  for type in A AAAA MX NS TXT CAA; do printf '\n%b[%s]%b\n' "$_DX_C" "$type" "$_DX_R"; dig +time=3 +tries=1 +short "$host" "$type" 2>/dev/null || true; done
  printf '\n%bDMARC record%b\n' "$_DX_G" "$_DX_R"; dig +time=3 +tries=1 +short "_dmarc.$host" TXT 2>/dev/null || true
  _dx_end
}

dermux_publicip(){
  printf '%bPrivacy note:%b this contacts api.ipify.org; that service can see your connection IP.\nContinue? [y/N] ' "$_DX_Y" "$_DX_R"
  local answer; read -r answer
  case "$answer" in [yY]|[yY][eE][sS]) curl -fsS --max-time 7 https://api.ipify.org && printf '\n' || echo 'Could not reach the service.';; *) echo 'Cancelled.';; esac
}

dermux_osint(){
  local host record result
  host="${1:-}"
  if [ -z "$host" ]; then _dx_prompt_domain 'Passive OSINT domain'; [ $? -eq 0 ] || return 2; host="$_dx_target"; fi
  host="${host#https://}"; host="${host#http://}"; host="${host%%/*}"; host="${host%%:*}"
  if ! _dx_valid_domain "$host"; then echo 'Invalid domain. Example: example.com'; return 2; fi
  _dx_banner; _dx_rule "PASSIVE OSINT · $host"
  printf '%bThis queries public records only: WHOIS, DNS and certificate-transparency data.%b\n' "$_DX_Y" "$_DX_R"
  printf 'The domain may be sent to the services queried below. Use only for legitimate research.\n'
  printf '\n%b1 · WHOIS (first 35 lines)%b\n' "$_DX_G" "$_DX_R"
  if command -v whois >/dev/null 2>&1; then timeout 12 whois "$host" 2>/dev/null | head -n 35 || true; else echo 'whois not installed'; fi
  printf '\n%b2 · DNS records%b\n' "$_DX_G" "$_DX_R"
  for record in A AAAA MX NS TXT CAA; do printf '[%s] ' "$record"; dig +time=3 +tries=1 +short "$host" "$record" 2>/dev/null | head -n 8 | paste -sd '; ' -; done
  printf '\n[DMARC] '; dig +time=3 +tries=1 +short "_dmarc.$host" TXT 2>/dev/null | head -n 4 | paste -sd '; ' -
  printf '\n%b3 · Certificate Transparency (crt.sh, up to 40 unique names)%b\n' "$_DX_G" "$_DX_R"
  if command -v jq >/dev/null 2>&1; then
    result="$(curl -fsSL --max-time 15 --get --data-urlencode "q=%.$host" --data-urlencode 'output=json' https://crt.sh/ 2>/dev/null | jq -r 'if type == "array" then .[].name_value // empty else empty end' 2>/dev/null | tr '\r' '\n' | sort -u | head -n 40)"
    if [ -n "$result" ]; then printf '%s\n' "$result"; else echo 'No names returned or service unavailable.'; fi
  else echo 'jq not installed'; fi
  _dx_end
}

dermux_headers(){
  local host
  host="${1:-}"
  if [ -z "$host" ]; then _dx_prompt_domain 'HTTPS host for a HEAD request'; [ $? -eq 0 ] || return 2; host="$_dx_target"; fi
  host="${host#https://}"; host="${host#http://}"; host="${host%%/*}"; host="${host%%:*}"
  if ! _dx_valid_domain "$host"; then echo 'Invalid host.'; return 2; fi
  _dx_banner; _dx_rule "HTTPS RESPONSE HEADERS · $host"
  printf 'Sends a normal HTTPS HEAD request to the selected host.\n\n'
  curl -sSIL --max-time 12 --max-redirs 3 "https://$host/" 2>&1 | head -n 45
  _dx_end
}

dermux_tls(){
  local host
  host="${1:-}"
  if [ -z "$host" ]; then _dx_prompt_domain 'TLS host'; [ $? -eq 0 ] || return 2; host="$_dx_target"; fi
  if ! _dx_valid_domain "$host"; then echo 'Invalid host.'; return 2; fi
  _dx_banner; _dx_rule "TLS CERTIFICATE · $host"
  timeout 10 openssl s_client -connect "$host:443" -servername "$host" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates -fingerprint -sha256 2>&1 || echo 'Could not read a TLS certificate (offline, invalid host or no TLS service).'
  _dx_end
}

dermux_localports(){
  _dx_banner; _dx_rule 'LOCAL LISTENING PORTS'
  printf 'Shows local sockets on this Android device only.\n\n'
  if command -v ss >/dev/null 2>&1; then ss -tuln 2>/dev/null | head -n 40; else echo 'Install iproute2: pkg install iproute2'; fi
  _dx_end
}

dermux_lan_discovery(){
  local net prefix answer
  _dx_banner; _dx_rule 'LOCAL LAN DISCOVERY'
  echo 'Use only on a network you own or have permission to test.'
  net="$(ip -4 route 2>/dev/null | awk '$1 ~ /\// && $1 !~ /^127\./ {print $1; exit}')"
  if [ -n "$net" ]; then printf 'Detected local route: %s\n' "$net"; else echo 'Could not detect a route automatically.'; fi
  printf 'Network CIDR to discover (Enter = detected route): '; read -r answer
  [ -n "$answer" ] && net="$answer"
  if [[ ! "$net" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$ ]]; then echo 'Invalid IPv4 CIDR.'; return 2; fi
  prefix="${net#*/}"
  if [ "$prefix" -lt 24 ]; then echo 'Safety limit: this helper accepts /24 or smaller ranges only (prefix /24–/32).'; return 2; fi
  printf 'Run Nmap host discovery against %s? [y/N] ' "$net"; read -r answer
  case "$answer" in [yY]|[yY][eE][sS]) nmap -sn -- "$net";; *) echo 'Cancelled.';; esac
  _dx_end
}

dermux_filehash(){
  local file
  printf 'Path to a local file: '; read -r file
  file="${file#\"}"; file="${file%\"}"; file="${file#\'}"; file="${file%\'}"
  if [ ! -f "$file" ]; then echo 'File not found.'; return 2; fi
  printf '\n%bSHA-256%b\n' "$_DX_G" "$_DX_R"; sha256sum "$file" 2>/dev/null || shasum -a 256 "$file" 2>/dev/null || echo 'SHA-256 tool unavailable.'
}

dermux_note(){
  mkdir -p "$HOME/DERMUX"
  printf 'Note text: '; local line; IFS= read -r line
  [ -n "$line" ] || { echo 'Empty note skipped.'; return 0; }
  printf '[%s] %s\n' "$(date '+%F %T')" "$line" >> "$HOME/DERMUX/notes.txt"
  echo "Saved to $HOME/DERMUX/notes.txt"
}

dermux_update(){
  printf 'This updates Termux packages. Review any package changes. Continue? [y/N] '; local answer; read -r answer
  case "$answer" in [yY]|[yY][eE][sS]) pkg update && pkg upgrade;; *) echo 'Cancelled.';; esac
}

dermux_processes(){
  if command -v htop >/dev/null 2>&1; then htop; else ps -A 2>/dev/null | head -n 60; fi
}

dermux_widgetdoctor(){
  _dx_banner; _dx_rule 'WIDGET DOCTOR'
  printf '\n%b1 · Shortcuts and folders%b\n' "$_DX_G" "$_DX_R"
  if [ -d "$HOME/.shortcuts" ]; then
    find "$HOME/.shortcuts" -type f -name '*.sh' ! -path '*/tasks/*' -print 2>/dev/null | sed "s|$HOME/.shortcuts/|  |" | sort
    printf '\n'
  else echo 'MISSING: ~/.shortcuts'; fi
  printf '%b2 · Permissions%b\n' "$_DX_G" "$_DX_R"
  ls -ld "$HOME/.shortcuts" "$HOME/.shortcuts/system" "$HOME/.shortcuts/network" "$HOME/.shortcuts/osint" "$HOME/.shortcuts/dev" "$HOME/.shortcuts/files" "$HOME/.shortcuts/tools" "$HOME/.shortcuts/tasks" "$HOME/.shortcuts/icons" 2>/dev/null || true
  printf '\n%b3 · Termux:Widget add-on%b\n' "$_DX_G" "$_DX_R"
  if command -v pm >/dev/null 2>&1 && pm path com.termux.widget 2>/dev/null | grep -q '^package:'; then echo 'Detected by Android package manager.'; else echo 'Not detected here. Check the add-on is installed and signed from a compatible source.'; fi
  printf '\n%b4 · Refresh request%b\n' "$_DX_G" "$_DX_R"
  if command -v am >/dev/null 2>&1; then am broadcast -n com.termux.widget/.TermuxWidgetProvider -a com.termux.widget.ACTION_REFRESH_WIDGET --ei appWidgetId 0 2>&1 | tail -n 8; else echo 'Android broadcast service unavailable.'; fi
  printf '\nThen open Termux:Widget itself → tap REFRESH → Android Home → Widgets → Termux:Widget.\n'
  printf 'The 2×2 widget is a shortcut list, not a live dashboard. For custom icons, add a 1×1 Termux shortcut for an individual script.\n'
  _dx_end
}

dermux_help(){
  _dx_banner; _dx_rule 'COMMAND MAP'
  cat <<'HELP'
  dermux / menu      Interactive command center
  dashboard          Battery, Wi-Fi, memory, storage, local IP
  sysinfo            Alias of dashboard
  netinfo            Local address, route and local listening sockets
  battery / wifi     Termux:API status (Android app may be required)
  dns DOMAIN         DNS records A, AAAA, MX, NS, TXT, CAA, DMARC
  osint DOMAIN       Passive WHOIS + DNS + crt.sh names (public records)
  headers DOMAIN     Normal HTTPS HEAD request
  tls DOMAIN         Read public TLS certificate details
  publicip           External IP lookup; asks first
  ports              Local listening ports only
  landiscovery       Optional local /24-/32 Nmap discovery, asks first
  storage            Storage usage summary
  hashfile           SHA-256 hash for a local file
  note               Append a timestamped note in ~/DERMUX/notes.txt
  processes          Local process viewer
  update             Update packages; asks first
  widgetdoctor       Diagnose shortcuts / request widget refresh
  help               Show this command map

  Convenience: c=clear, ll=list files, e=dermux, ..=parent folder
  Safety: only test networks/systems you own or have explicit permission to test.
HELP
  _dx_end
}

dermux_menu(){
  local choice
  while true; do
    printf '\n%b╭──────────── D E R M U X  //  @ O S A O D A ────────────╮%b\n' "$_DX_C" "$_DX_R"
    printf '  [1] Dashboard             [2] Network information\n'
    printf '  [3] Passive OSINT         [4] DNS lookup\n'
    printf '  [5] HTTPS headers         [6] TLS certificate\n'
    printf '  [7] Battery / Wi-Fi       [8] Storage report\n'
    printf '  [9] Local ports           [10] Widget Doctor\n'
    printf '  [11] Quick note           [12] Package update\n'
    printf '  [h] Help                  [q] Quit\n'
    printf 'Select: '; read -r choice
    case "$choice" in
      1) dermux_dashboard;; 2) dermux_netinfo;; 3) dermux_osint;; 4) dermux_dns;;
      5) dermux_headers;; 6) dermux_tls;; 7) dermux_battery; dermux_wifi;; 8) dermux_storage;;
      9) dermux_localports;; 10) dermux_widgetdoctor;; 11) dermux_note;; 12) dermux_update;;
      h|H) dermux_help;; q|Q) break;; *) echo 'Choose one of the listed options.';;
    esac
  done
}

dermux_widget(){
  case "${1:-help}" in
    dashboard) dermux_dashboard;; battery) dermux_battery;; wifi) dermux_wifi;;
    network) dermux_netinfo;; dns) dermux_dns;; osint) dermux_osint;; headers) dermux_headers;; tls) dermux_tls;;
    publicip) dermux_publicip;; ports) dermux_localports;; lan) dermux_lan_discovery;; storage) dermux_storage;;
    hash) dermux_filehash;; note) dermux_note;; update) dermux_update;; processes) dermux_processes;;
    doctor) dermux_widgetdoctor;; help) dermux_help;; menu) dermux_menu;;
    *) echo "Unknown DERMUX widget action: $1"; return 2;;
  esac
}


# ── DERMUX ULTRA v4 extensions ──────────────────────────────────────────────
# These helpers are intentionally local-first. External requests require consent.
_DU_Y='\033[38;5;220m'; _DU_C='\033[38;5;51m'; _DU_R='\033[0m'
_du_confirm(){ printf '%bThis will contact an external host/service.%b\n%s\nContinue? [y/N] ' "$_DU_Y" "$_DU_R" "$1"; local a; read -r a; case "$a" in y|Y|yes|YES) return 0;; *) echo 'Cancelled; no request sent.'; return 1;; esac; }
_du_domain_ok(){ local h="${1:-}"; [[ "$h" =~ ^([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z0-9-]{2,63}$ ]] && [ "${#h}" -le 253 ] && [[ "$h" != *..* ]]; }
_du_prompt_domain(){ local h; printf '%s: ' "$1"; read -r h; h="${h#https://}"; h="${h#http://}"; h="${h%%/*}"; h="${h%%:*}"; h="${h%.}"; _du_domain_ok "$h" || { echo 'Invalid domain; use a hostname such as example.com.'; return 2; }; _DU_HOST="$h"; }

# Live mode refreshes the terminal only; it is not a background phone service.
dermux_live(){ local stop=0; printf 'DERMUX live view · refresh 4 sec · Ctrl+C to stop\n'; trap 'stop=1' INT TERM; while [ "$stop" -eq 0 ]; do dermux_dashboard; printf '\nLive view · Ctrl+C to stop\n'; sleep 4 || true; done; trap - INT TERM; }
dermux_memory(){ _dx_banner; _dx_rule 'MEMORY REPORT'; awk '/MemTotal|MemAvailable|MemFree|Cached|SwapTotal|SwapFree/ {printf "%-16s %.0f MB\n",$1,$2/1024}' /proc/meminfo 2>/dev/null || echo 'Memory data unavailable.'; _dx_end; }
dermux_uptime(){ _dx_banner; _dx_rule 'UPTIME / LOAD'; uptime 2>/dev/null || cat /proc/uptime; printf '\nLoad average: '; cat /proc/loadavg 2>/dev/null | awk '{print $1 " / " $2 " / " $3}'; _dx_end; }
dermux_apps(){ _dx_banner; _dx_rule 'INSTALLED APP PACKAGE NAMES'; if command -v pm >/dev/null 2>&1; then pm list packages -3 2>/dev/null | sed 's/^package://' | sort | head -n 100; else echo 'Android package manager is unavailable from this shell.'; fi; echo '\nOnly package names are shown; app data is not accessed.'; _dx_end; }
dermux_gitstatus(){ if ! command -v git >/dev/null 2>&1; then echo 'git is not installed.'; elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then git status --short --branch; else echo 'This directory is not a Git repository.'; fi; }
dermux_jsonpretty(){ local f; printf 'Local JSON file path: '; read -r f; f="${f#\"}"; f="${f%\"}"; [ -f "$f" ] || { echo 'File not found.'; return 2; }; if command -v jq >/dev/null 2>&1; then jq . "$f"; else python -m json.tool "$f"; fi; }
dermux_urlencode(){ local x; printf 'Text to URL-encode: '; IFS= read -r x; printf '%s' "$x" | python -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read(),safe=""))'; }
dermux_urldecode(){ local x; printf 'Text to URL-decode: '; IFS= read -r x; printf '%s' "$x" | python -c 'import sys,urllib.parse; print(urllib.parse.unquote_plus(sys.stdin.read()))'; }
dermux_b64encode(){ local x; printf 'Text to Base64-encode: '; IFS= read -r x; printf '%s' "$x" | base64 | tr -d '\n'; printf '\n'; }
dermux_b64decode(){ local x; printf 'Base64 text to decode: '; IFS= read -r x; printf '%s' "$x" | base64 -d 2>/dev/null || { echo 'Invalid Base64 input.'; return 2; }; printf '\n'; }
dermux_calc(){ local x; printf 'Arithmetic only (example: (12+3)*4/5): '; IFS= read -r x; DERMUX_EXPR="$x" python - <<'PY'
import ast,os,operator,math
ops={ast.Add:operator.add,ast.Sub:operator.sub,ast.Mult:operator.mul,ast.Div:operator.truediv,ast.FloorDiv:operator.floordiv,ast.Mod:operator.mod,ast.Pow:operator.pow,ast.UAdd:operator.pos,ast.USub:operator.neg}
def calc(n):
 if isinstance(n,ast.Expression): return calc(n.body)
 if isinstance(n,ast.Constant) and type(n.value) in (int,float): return n.value
 if isinstance(n,ast.UnaryOp) and type(n.op) in ops: return ops[type(n.op)](calc(n.operand))
 if isinstance(n,ast.BinOp) and type(n.op) in ops:
  a,b=calc(n.left),calc(n.right)
  if isinstance(n.op,ast.Pow) and (abs(b)>10 or abs(a)>1e9): raise ValueError('power too large')
  if isinstance(n.op,(ast.Div,ast.FloorDiv,ast.Mod)) and b==0: raise ValueError('division by zero')
  v=ops[type(n.op)](a,b)
  if isinstance(v,(int,float)) and (abs(v)>1e100 or not math.isfinite(float(v))): raise ValueError('result too large')
  return v
 raise ValueError('numbers and arithmetic operators only; no code execution')
try: print(calc(ast.parse(os.environ.get('DERMUX_EXPR',''),mode='eval')))
except Exception as e: print('Invalid expression:',e); raise SystemExit(2)
PY
}
dermux_countlines(){ local f; printf 'Local file path: '; read -r f; f="${f#\"}"; f="${f%\"}"; [ -f "$f" ] || { echo 'File not found.'; return 2; }; wc -l -w -c "$f"; }
dermux_findfile(){ local root pattern; printf 'Search folder (Enter = $HOME): '; read -r root; [ -n "$root" ] || root="$HOME"; [ -d "$root" ] || { echo 'Folder not found.'; return 2; }; printf 'Name contains: '; read -r pattern; [ -n "$pattern" ] || { echo 'Search cannot be empty.'; return 2; }; find "$root" -maxdepth 6 -type f -iname "*$pattern*" -print 2>/dev/null | head -n 80; }
dermux_archiveinfo(){ local f; printf 'Archive path (zip/tar/tgz): '; read -r f; f="${f#\"}"; f="${f%\"}"; [ -f "$f" ] || { echo 'File not found.'; return 2; }; case "$f" in *.zip) unzip -l "$f" | head -n 100;; *.tar|*.tar.gz|*.tgz|*.tar.xz|*.tar.bz2) tar -tf "$f" 2>/dev/null | head -n 100;; *) echo 'Supported formats: zip, tar, tgz, tar.gz, tar.xz, tar.bz2.';; esac; echo 'Listing only — nothing was extracted.'; }
dermux_httpstatus(){ local host; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'HTTPS domain' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid domain.'; return 2; }; _du_confirm "HTTPS status check for $host" || return 0; curl -sS -o /dev/null --max-time 12 --max-redirs 4 -w 'HTTP: %{http_code}\nRemote IP: %{remote_ip}\nElapsed: %{time_total}s\nRedirects: %{num_redirects}\n' "https://$host/" || echo 'Request failed.'; }
# The v4 DNS wrapper now requires consent before sending a query.
dermux_dns(){ local host typ; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'DNS domain' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid domain.'; return 2; }; _du_confirm "DNS records for $host" || return 0; _dx_banner; _dx_rule "DNS · $host"; for typ in A AAAA MX NS TXT CAA SOA; do printf '\n[%s]\n' "$typ"; dig +time=3 +tries=1 +short "$host" "$typ" 2>/dev/null | head -n 15; done; printf '\n[DMARC]\n'; dig +time=3 +tries=1 +short "_dmarc.$host" TXT 2>/dev/null | head -n 6; _dx_end; }
# Add explicit consent to the existing public-source helpers by wrapping the function with a v4 variant.
_DERMUX_OLD_WHOIS="$(declare -f dermux_whois 2>/dev/null || true)"
dermux_whois(){ local host; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'WHOIS domain' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid domain.'; return 2; }; _du_confirm "WHOIS lookup for $host" || return 0; timeout 12 whois "$host" 2>/dev/null | head -n 80 || echo 'WHOIS request failed or whois is unavailable.'; }
dermux_rdap(){ local host; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'RDAP domain' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid domain.'; return 2; }; _du_confirm "RDAP registration request for $host" || return 0; curl -fsSL --max-time 15 "https://rdap.org/domain/$host" 2>/dev/null | jq '{handle,ldhName,status,events:([.events[]? | {eventAction,eventDate}]),nameservers:([.nameservers[]?.ldhName])}' 2>/dev/null || echo 'RDAP request failed.'; }
dermux_ct(){ local host; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'Certificate Transparency domain' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid domain.'; return 2; }; _du_confirm "Public Certificate Transparency query for $host" || return 0; curl -fsSL --max-time 18 --get --data-urlencode "q=%.$host" --data-urlencode 'output=json' 'https://crt.sh/' 2>/dev/null | jq -r 'if type=="array" then .[].name_value // empty else empty end' 2>/dev/null | tr '\r' '\n' | sed 's/^\*\.//' | sort -fu | head -n 80 || echo 'No data returned.'; }
dermux_headers(){ local host; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'HTTPS host' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid host.'; return 2; }; _du_confirm "HTTPS headers request to $host" || return 0; curl -sSIL --max-time 12 --max-redirs 4 "https://$host/" 2>&1 | head -n 55; }
dermux_tls(){ local host; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'TLS certificate hostname' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid host.'; return 2; }; _du_confirm "TLS handshake with $host:443" || return 0; timeout 10 openssl s_client -connect "$host:443" -servername "$host" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates -fingerprint -sha256 2>&1 || echo 'TLS certificate unavailable.'; }
dermux_robots(){ local host; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'robots.txt hostname' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid host.'; return 2; }; _du_confirm "Fetch public robots.txt from $host" || return 0; curl -fsSL --max-time 10 "https://$host/robots.txt" 2>/dev/null | head -n 100 || echo 'robots.txt unavailable.'; }
dermux_osint(){ local host choice; if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; else _du_prompt_domain 'Passive OSINT domain' || return 2; host="$_DU_HOST"; fi; _du_domain_ok "$host" || { echo 'Invalid domain.'; return 2; }; while :; do _dx_banner; _dx_rule "PASSIVE OSINT · $host"; printf '[1] DNS   [2] WHOIS   [3] RDAP   [4] CT hostnames\n[5] HTTPS headers   [6] TLS   [7] robots.txt   [q] Back\nChoose: '; read -r choice; case "$choice" in 1) dermux_dns "$host";; 2) dermux_whois "$host";; 3) dermux_rdap "$host";; 4) dermux_ct "$host";; 5) dermux_headers "$host";; 6) dermux_tls "$host";; 7) dermux_robots "$host";; q|Q) return;; *) echo 'Invalid selection.';; esac; printf '\nEnter to return '; read -r _; done; }
# Keep LAN discovery limited to RFC1918 private ranges /24–/32 and ask explicitly.
dermux_lan_discovery(){ local net ans norm; _dx_banner; _dx_rule 'LOCAL LAN DISCOVERY'; echo 'For networks you own or are authorized to test only.'; net="$(ip -4 route 2>/dev/null | awk '$1 ~ /\// && $1 !~ /^127\./ {print $1; exit}')"; printf 'CIDR (Enter = %s): ' "${net:-none}"; read -r ans; [ -n "$ans" ] && net="$ans"; [ -n "$net" ] || { echo 'No private CIDR supplied/detected.'; return 2; }; norm="$(python - "$net" 2>/dev/null <<'PYIP'
import ipaddress,sys
try:
 n=ipaddress.ip_network(sys.argv[1],strict=False)
 allowed=[ipaddress.ip_network('10.0.0.0/8'),ipaddress.ip_network('172.16.0.0/12'),ipaddress.ip_network('192.168.0.0/16')]
 if n.version!=4 or n.prefixlen<24 or not any(n.subnet_of(x) for x in allowed): raise ValueError()
 print(n)
except Exception: raise SystemExit(2)
PYIP
)" || { echo 'Rejected: only an RFC1918 private IPv4 CIDR /24 through /32 is allowed.'; return 2; }; printf 'Scan %s with nmap host discovery? [y/N] ' "$norm"; read -r ans; case "$ans" in y|Y|yes|YES) nmap -sn -- "$norm";; *) echo 'Cancelled.';; esac; }
# Package sources can run install scripts. Inspect them before package changes.
dermux_repoaudit(){ _dx_banner; _dx_rule 'PACKAGE SOURCE AUDIT'; local f found=0; for f in "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.d"/*.list "$PREFIX/etc/apt/sources.list.d"/*.sources; do [ -f "$f" ] || continue; if grep -Eq '^[[:space:]]*(deb[[:space:]]|URIs:|Types:)' "$f"; then printf '\n-- %s --\n' "$f"; grep -E '^[[:space:]]*(deb[[:space:]]|URIs:|Suites:|Types:|Components:)' "$f" | head -n 80; found=1; fi; done; [ "$found" = 1 ] || echo 'No package sources found in expected locations.'; echo '\nNever install packages from unrecognized sources. This audit makes no changes.'; _dx_end; }
dermux_healthcheck(){ _dx_banner; _dx_rule 'HEALTH CHECK'; local c; for c in bash zsh starship git curl jq python openssl dig whois nmap termux-battery-status termux-wifi-connectioninfo; do if command -v "$c" >/dev/null 2>&1; then printf '[OK] %s\n' "$c"; else printf '[OPTIONAL/MISSING] %s\n' "$c"; fi; done; echo; [ -d "$HOME/.shortcuts" ] && echo '[OK] shortcuts directory' || echo '[MISSING] shortcuts directory'; command -v pm >/dev/null 2>&1 && pm path com.termux.widget 2>/dev/null | grep -q '^package:' && echo '[OK] Termux:Widget detected' || echo '[NOTE] Termux:Widget not detected'; _dx_end; }
# Override the main menu to surface all categories without overflowing small screens.
dermux_menu(){ local c; while :; do _dx_banner; _dx_rule 'ULTRA COMMAND CENTER · @OSAODA'; printf '[1] Dashboard / live view\n[2] System tools\n[3] Network tools\n[4] Passive OSINT\n[5] Developer toolbox\n[6] Files / notes / backups\n[7] Widget Doctor\n[8] Repository audit\n[9] Health check\n[h] Help   [q] Quit\nSelect: '; read -r c || return; case "$c" in 1) printf '[1] Snapshot  [2] Live: '; read -r c; case "$c" in 2) dermux_live;; *) dermux_dashboard;; esac;; 2) printf '[1] Battery  [2] Wi-Fi  [3] Memory  [4] Storage  [5] Processes  [6] Uptime  [7] Apps\nChoose: '; read -r c; case "$c" in 1) dermux_battery;; 2) dermux_wifi;; 3) dermux_memory;; 4) dermux_storage;; 5) dermux_processes;; 6) dermux_uptime;; 7) dermux_apps;; esac;; 3) printf '[1] Net info [2] Local ports [3] Ping host [4] Trace route [5] HTTP status [6] Public IP [7] LAN discovery\nChoose: '; read -r c; case "$c" in 1) dermux_netinfo;; 2) dermux_localports;; 3) dermux_widget ping;; 4) dermux_widget trace;; 5) dermux_httpstatus;; 6) dermux_publicip;; 7) dermux_lan_discovery;; esac;; 4) dermux_osint;; 5) printf '[1] SHA-256 [2] JSON [3] URL encode [4] URL decode [5] Base64 encode [6] Base64 decode [7] Calculator [8] Python [9] Git status\nChoose: '; read -r c; case "$c" in 1) dermux_filehash;; 2) dermux_jsonpretty;; 3) dermux_urlencode;; 4) dermux_urldecode;; 5) dermux_b64encode;; 6) dermux_b64decode;; 7) dermux_calc;; 8) python;; 9) dermux_gitstatus;; esac;; 6) printf '[1] Note [2] Find file [3] Count lines [4] Archive info [5] Backup config\nChoose: '; read -r c; case "$c" in 1) dermux_note;; 2) dermux_findfile;; 3) dermux_countlines;; 4) dermux_archiveinfo;; 5) dermux_backup;; esac;; 7) dermux_widgetdoctor;; 8) dermux_repoaudit;; 9) dermux_healthcheck;; h|H) dermux_help;; q|Q) return;; *) echo 'Choose one of the listed options.';; esac; printf '\nEnter → return '; read -r _; done; }
# Extend the dispatcher used by widget wrapper scripts.
_dermux_old_widget="$(declare -f dermux_widget 2>/dev/null || true)"

# Additional network actions: one target at a time, explicit consent, bounded runtime.
_du_host_or_ip_ok(){
  local h="${1:-}"
  _du_domain_ok "$h" || [[ "$h" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}
dermux_ping(){
  local host
  if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; host="${host%%:*}"; else printf 'Host or IPv4 to ping: '; read -r host; fi
  _du_host_or_ip_ok "$host" || { echo 'Enter a valid hostname or IPv4 address.'; return 2; }
  _du_confirm "Send 4 ping probes to $host" || return 0
  command -v ping >/dev/null 2>&1 || { echo 'ping is not installed.'; return 127; }
  ping -c 4 -W 2 "$host"
}
dermux_trace(){
  local host
  if [ -n "${1:-}" ]; then host="${1#https://}"; host="${host#http://}"; host="${host%%/*}"; host="${host%%:*}"; else printf 'Host to trace: '; read -r host; fi
  _du_host_or_ip_ok "$host" || { echo 'Enter a valid hostname or IPv4 address.'; return 2; }
  _du_confirm "Trace route to $host (maximum 12 hops)" || return 0
  command -v traceroute >/dev/null 2>&1 || { echo 'traceroute is not installed.'; return 127; }
  traceroute -m 12 -w 2 "$host"
}
dermux_matrix(){
  command -v python >/dev/null 2>&1 || { echo 'Python is required for Matrix Rain.'; return 127; }
  python - <<'PY_MATRIX'
import random, shutil, sys, time
w=max(30, min(shutil.get_terminal_size((80,24)).columns, 120))
chars='01アイウエオカキクケコサシスセソタチツテトナニヌネノ'
try:
    sys.stdout.write('\033[2J\033[?25l')
    for _ in range(55):
        row=''.join(random.choice(chars+'   ') for _ in range(w))
        sys.stdout.write('\033[38;5;48m'+row+'\033[0m\n')
        sys.stdout.flush(); time.sleep(0.055)
except KeyboardInterrupt:
    pass
finally:
    sys.stdout.write('\033[0m\033[?25h\n'); sys.stdout.flush()
PY_MATRIX
}
# Use one explicit allowlist; no eval or user-controlled function names.
dermux_widget_dispatch(){
  local action="${1:-help}"
  case "$action" in
    menu|hub|core|dermux) dermux_menu;;
    dashboard) dermux_dashboard;; live) dermux_live;; battery) dermux_battery;; wifi) dermux_wifi;;
    memory) dermux_memory;; uptime) dermux_uptime;; apps) dermux_apps;; storage) dermux_storage;;
    network|netinfo) dermux_netinfo;; ports) dermux_localports;; processes) dermux_processes;;
    ping) dermux_ping "${2:-}";; trace) dermux_trace "${2:-}";; httpstatus) dermux_httpstatus "${2:-}";;
    publicip) dermux_publicip;; lan) dermux_lan_discovery;;
    dns) dermux_dns "${2:-}";; whois|whoisdomain) dermux_whois "${2:-}";; rdap) dermux_rdap "${2:-}";;
    ct|ctlookup) dermux_ct "${2:-}";; headers) dermux_headers "${2:-}";; tls) dermux_tls "${2:-}";;
    robots) dermux_robots "${2:-}";; osint) dermux_osint "${2:-}";;
    hash|hashfile) dermux_filehash;; note) dermux_note;; update|updatepackages) dermux_update;;
    doctor|widgetdoctor) dermux_widgetdoctor;; help) dermux_help;; repoaudit) dermux_repoaudit;;
    healthcheck) dermux_healthcheck;; matrix) dermux_matrix;;
    json|jsonpretty) dermux_jsonpretty;; urlencode) dermux_urlencode;; urldecode) dermux_urldecode;;
    b64encode) dermux_b64encode;; b64decode) dermux_b64decode;; calc) dermux_calc;;
    git|gitstatus) dermux_gitstatus;; count|countlines) dermux_countlines;; find|findfile) dermux_findfile;;
    archive|archiveinfo) dermux_archiveinfo;; backup)
      if [ -x "$HOME/.shortcuts/tasks/DERMUX-Config-Backup.sh" ]; then "$HOME/.shortcuts/tasks/DERMUX-Config-Backup.sh"; else echo 'Backup task is missing; reinstall the DERMUX bundle.'; return 1; fi;;
    *) printf 'Unknown DERMUX action: %s\nRun help for the command map.\n' "$action"; return 2;;
  esac
}
dermux_widget(){ dermux_widget_dispatch "$@"; }
