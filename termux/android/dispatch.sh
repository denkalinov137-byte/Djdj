#!/data/data/com.termux/files/usr/bin/bash
# DERMUX RU // by @osaoda — safe allowlisted bridge from the Android radial menu.
set -u
source "$HOME/.config/dermux/dermux.sh" || { echo 'DERMUX shell library is missing. Run install-termux.sh from the bundle.'; exit 1; }
action="${1:-help}"
target="${2:-}"

valid_domain(){ _du_domain_ok "${1:-}"; }
valid_ip(){ python - "$1" >/dev/null 2>&1 <<'PYIP'
import ipaddress,sys
try:
    ip=ipaddress.ip_address(sys.argv[1])
    if ip.version != 4 or not ip.is_global: raise ValueError()
except Exception: raise SystemExit(2)
PYIP
}

case "$action" in
  # System
  dashboard) dermux_dashboard;;
  battery) dermux_battery;;
  wifi) dermux_wifi;;
  memory) dermux_memory;;
  storage) dermux_storage;;
  processes) dermux_processes;;
  uptime) dermux_uptime;;
  snapshot)
    mkdir -p "$HOME/DERMUX/reports"
    out="$HOME/DERMUX/reports/snapshot-$(date +%Y%m%d-%H%M%S).txt"
    {
      echo 'DERMUX RU — локальный снимок состояния'; date; echo
      echo '[device]'; getprop ro.product.model 2>/dev/null | head -n 1
      echo '[uptime]'; uptime 2>/dev/null || cat /proc/uptime
      echo '[memory]'; awk '/MemTotal|MemAvailable|SwapTotal|SwapFree/ {print}' /proc/meminfo 2>/dev/null
      echo '[storage]'; df -h "$HOME" 2>/dev/null
      echo '[local-ip]'; ip -o -4 addr show scope global 2>/dev/null
    } > "$out"
    echo "Отчёт сохранён: $out";;

  # Network
  netinfo) dermux_netinfo;;
  ports) dermux_localports;;
  dns) [ -n "$target" ] || { echo 'Нужен домен.'; exit 2; }; dermux_dns "$target";;
  ping) [ -n "$target" ] || { echo 'Нужен домен или IPv4.'; exit 2; }; dermux_ping "$target";;
  trace) [ -n "$target" ] || { echo 'Нужен домен или IPv4.'; exit 2; }; dermux_trace "$target";;
  httpstatus) [ -n "$target" ] || { echo 'Нужен домен.'; exit 2; }; dermux_httpstatus "$target";;
  publicip) dermux_publicip;;
  lan) dermux_lan_discovery;;

  # Passive OSINT and public web metadata. No brute-force or hidden-data access.
  osint)
    valid_domain "$target" || { echo 'Некорректный домен.'; exit 2; }
    _du_confirm "Сводная пассивная OSINT-проверка для $target (DNS + WHOIS + RDAP + Certificate Transparency)" || exit 0
    _dx_banner; _dx_rule "OSINT-ОБЗОР · $target"
    echo '[1] DNS'; for typ in A AAAA MX NS TXT CAA; do printf '\n[%s]\n' "$typ"; dig +time=3 +tries=1 +short "$target" "$typ" 2>/dev/null | head -n 8; done
    echo; echo '[2] WHOIS (первые 30 строк)'; timeout 10 whois "$target" 2>/dev/null | head -n 30 || echo 'WHOIS недоступен.'
    echo; echo '[3] RDAP summary'; curl -fsSL --max-time 12 "https://rdap.org/domain/$target" 2>/dev/null | jq '{ldhName,status,events:([.events[]? | {eventAction,eventDate}]),nameservers:([.nameservers[]?.ldhName])}' 2>/dev/null || echo 'RDAP недоступен.'
    echo; echo '[4] Certificate Transparency (до 25 имён)'; curl -fsSL --max-time 15 --get --data-urlencode "q=%.$target" --data-urlencode 'output=json' 'https://crt.sh/' 2>/dev/null | jq -r 'if type=="array" then .[].name_value // empty else empty end' 2>/dev/null | tr '\r' '\n' | sed 's/^\*\.//' | sort -fu | head -n 25 || true
    _dx_end;;
  whois) [ -n "$target" ] || { echo 'Нужен домен.'; exit 2; }; dermux_whois "$target";;
  rdap) [ -n "$target" ] || { echo 'Нужен домен.'; exit 2; }; dermux_rdap "$target";;
  ct) [ -n "$target" ] || { echo 'Нужен домен.'; exit 2; }; dermux_ct "$target";;
  headers) [ -n "$target" ] || { echo 'Нужен домен.'; exit 2; }; dermux_headers "$target";;
  tls) [ -n "$target" ] || { echo 'Нужен домен.'; exit 2; }; dermux_tls "$target";;
  robots) [ -n "$target" ] || { echo 'Нужен домен.'; exit 2; }; dermux_robots "$target";;
  txtrecords)
    valid_domain "$target" || { echo 'Некорректный домен.'; exit 2; }
    _du_confirm "Публичный DNS TXT-запрос для $target" || exit 0
    echo "TXT для $target"; dig +time=3 +tries=1 +short "$target" TXT 2>/dev/null | head -n 35;;
  emailsec)
    valid_domain "$target" || { echo 'Некорректный домен.'; exit 2; }
    _du_confirm "Проверка публичных SPF/DMARC/DKIM TXT-записей для $target" || exit 0
    echo "[SPF/TXT · $target]"; dig +time=3 +tries=1 +short "$target" TXT 2>/dev/null | head -n 25
    echo "[DMARC]"; dig +time=3 +tries=1 +short "_dmarc.$target" TXT 2>/dev/null | head -n 12
    for selector in default selector1 selector2 google s1 mail; do
      value="$(dig +time=2 +tries=1 +short "$selector._domainkey.$target" TXT 2>/dev/null | head -n 1)"
      [ -z "$value" ] || printf '[DKIM %s] %s\n' "$selector" "$value"
    done;;
  sectxt)
    valid_domain "$target" || { echo 'Некорректный домен.'; exit 2; }
    _du_confirm "Запрос публичного security.txt у $target" || exit 0
    tmp="$(mktemp)" || exit 1
    if curl -fsSL --max-time 10 --max-filesize 500000 "https://$target/.well-known/security.txt" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      head -n 80 "$tmp"
    elif curl -fsSL --max-time 8 --max-filesize 500000 "https://$target/security.txt" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      echo 'Файл найден в /security.txt:'; head -n 80 "$tmp"
    else echo 'security.txt не найден или недоступен.'; fi
    rm -f "$tmp";;
  sitemap)
    valid_domain "$target" || { echo 'Некорректный домен.'; exit 2; }
    _du_confirm "Запрос публичного sitemap.xml у $target" || exit 0
    tmp="$(mktemp)" || exit 1
    if curl -fsSL --max-time 12 --max-filesize 1500000 "https://$target/sitemap.xml" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then head -c 12000 "$tmp"; else echo 'sitemap.xml недоступен.'; fi
    rm -f "$tmp";;
  iprdap)
    valid_ip "$target" || { echo 'Нужен публичный глобальный IPv4-адрес (не частный/локальный).'; exit 2; }
    _du_confirm "Публичный RDAP-запрос для IP $target" || exit 0
    curl -fsSL --max-time 15 "https://rdap.org/ip/$target" 2>/dev/null | jq '{name,handle,startAddress,endAddress,ipVersion,country,port43,entities:([.entities[]?.handle])}' 2>/dev/null || echo 'RDAP для IP недоступен.';;
  webtitle)
    valid_domain "$target" || { echo 'Некорректный домен.'; exit 2; }
    _du_confirm "Получение открытой главной страницы https://$target/ (только title)" || exit 0
    curl -fsSL --max-time 12 --max-filesize 2000000 -A 'DERMUX-RU/1.0 (manual web metadata check)' "https://$target/" 2>/dev/null \
      | python -c 'import sys;from html.parser import HTMLParser
class P(HTMLParser):
 def __init__(self):super().__init__();self.on=False;self.s=[]
 def handle_starttag(self,t,a):self.on=(t.lower()=="title") or self.on
 def handle_endtag(self,t):
  if t.lower()=="title":self.on=False
 def handle_data(self,d):
  if self.on:self.s.append(d.strip())
p=P();p.feed(sys.stdin.read(200000));print("HTML title: "+(" ".join(x for x in p.s if x)[:300] or "(пусто/не найдено)"))' || echo 'Не удалось получить заголовок страницы.';;
  redirects)
    valid_domain "$target" || { echo 'Некорректный домен.'; exit 2; }
    _du_confirm "Проверка HTTPS-цепочки редиректов для $target" || exit 0
    curl -sSIL --max-time 15 --max-redirs 5 -o /dev/null \
      -w 'HTTP: %{http_code}\nНачальный URL: %{url}\nФинальный URL: %{redirect_url}\nРедиректов: %{num_redirects}\nIP: %{remote_ip}\nВремя: %{time_total}s\n' "https://$target/" 2>&1;;
  faviconhash)
    valid_domain "$target" || { echo 'Некорректный домен.'; exit 2; }
    _du_confirm "Получение публичного favicon с $target и вычисление его хэша" || exit 0
    tmp="$(mktemp)" || exit 1
    if curl -fsSL --max-time 10 --max-filesize 2000000 "https://$target/favicon.ico" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      echo 'SHA-256:'; sha256sum "$tmp" 2>/dev/null || true
      echo 'MD5 (только идентификатор файла, не для безопасности):'; md5sum "$tmp" 2>/dev/null || true
      echo "Размер: $(wc -c < "$tmp") байт"
    else echo 'favicon.ico недоступен. Возможно, сайт использует другой путь или формат.'; fi
    rm -f "$tmp";;

  # Developer tools: all user data is passed as a single quoted argument, never eval'ed.
  jsonpretty)
    [ -f "$target" ] || { echo 'Файл не найден. Укажи путь к локальному JSON.'; exit 2; }
    if command -v jq >/dev/null 2>&1; then jq . "$target"; else python -m json.tool "$target"; fi;;
  urlencode) [ -n "$target" ] || { echo 'Пустая строка.'; exit 2; }; python -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1],safe=""))' "$target";;
  urldecode) python -c 'import sys,urllib.parse;print(urllib.parse.unquote_plus(sys.argv[1]))' "$target";;
  b64encode) printf '%s' "$target" | base64 | tr -d '\n'; printf '\n';;
  b64decode) printf '%s' "$target" | base64 -d 2>/dev/null || { echo 'Строка Base64 некорректна.'; exit 2; }; printf '\n';;
  hash)
    [ -f "$target" ] || { echo 'Файл не найден.'; exit 2; }
    sha256sum "$target" 2>/dev/null || shasum -a 256 "$target";;
  gitstatus) dermux_gitstatus;;
  calc)
    [ -n "$target" ] || { echo 'Нужно арифметическое выражение.'; exit 2; }
    DERMUX_EXPR="$target" python - <<'PYCALC'
import ast,os,operator,math
ops={ast.Add:operator.add,ast.Sub:operator.sub,ast.Mult:operator.mul,ast.Div:operator.truediv,ast.FloorDiv:operator.floordiv,ast.Mod:operator.mod,ast.Pow:operator.pow,ast.UAdd:operator.pos,ast.USub:operator.neg}
def calc(n):
 if isinstance(n,ast.Expression):return calc(n.body)
 if isinstance(n,ast.Constant) and type(n.value) in (int,float):return n.value
 if isinstance(n,ast.UnaryOp) and type(n.op) in ops:return ops[type(n.op)](calc(n.operand))
 if isinstance(n,ast.BinOp) and type(n.op) in ops:
  a,b=calc(n.left),calc(n.right)
  if isinstance(n.op,ast.Pow) and (abs(b)>10 or abs(a)>1e9):raise ValueError('слишком большая степень')
  if isinstance(n.op,(ast.Div,ast.FloorDiv,ast.Mod)) and b==0:raise ValueError('деление на ноль')
  v=ops[type(n.op)](a,b)
  if isinstance(v,(int,float)) and (abs(v)>1e100 or not math.isfinite(float(v))):raise ValueError('результат слишком велик')
  return v
 raise ValueError('разрешена только арифметика; код не исполняется')
try:print(calc(ast.parse(os.environ.get('DERMUX_EXPR',''),mode='eval')))
except Exception as e:print('Ошибка:',e);raise SystemExit(2)
PYCALC
    ;;
  count)
    [ -f "$target" ] || { echo 'Файл не найден.'; exit 2; }; wc -l -w -c "$target";;
  find)
    [ -n "$target" ] || { echo 'Укажи часть имени.'; exit 2; }
    echo "Поиск внутри $HOME (глубина до 5 каталогов):"
    find "$HOME" -maxdepth 5 -type f -iname "*$target*" -print 2>/dev/null | head -n 100;;
  archive)
    [ -f "$target" ] || { echo 'Архив не найден.'; exit 2; }
    case "$target" in
      *.zip) unzip -l "$target" | head -n 100;;
      *.tar|*.tar.gz|*.tgz|*.tar.xz|*.tar.bz2) tar -tf "$target" 2>/dev/null | head -n 100;;
      *) echo 'Форматы: zip, tar, tar.gz, tgz, tar.xz, tar.bz2.'; exit 2;;
    esac
    echo 'Только просмотр списка; архив не распаковывался.';;
  note)
    [ -n "$target" ] || { echo 'Пустая заметка не сохранена.'; exit 2; }
    mkdir -p "$HOME/DERMUX"; printf '[%s] %s\n' "$(date '+%F %T')" "$target" >> "$HOME/DERMUX/notes.txt"
    echo "Сохранено: $HOME/DERMUX/notes.txt";;
  backup)
    script="$HOME/.shortcuts/tasks/DERMUX-Config-Backup.sh"
    [ -x "$script" ] || { echo 'Сценарий резервного копирования не найден.'; exit 2; }
    "$script";;
  listfiles) find "$HOME" -maxdepth 2 -mindepth 1 -print 2>/dev/null | sort | head -n 120;;
  live) dermux_live;;
  healthcheck) dermux_healthcheck;;
  repoaudit) dermux_repoaudit;;
  widgetdoctor) dermux_widgetdoctor;;
  matrix) dermux_matrix;;
  help) dermux_help;;
  python) python;;
  update) dermux_update;;
  selfcheck)
    echo 'DERMUX Android bridge:'
    [ -r "$HOME/.config/dermux/dermux.sh" ] && echo '[OK] shell library' || echo '[MISSING] shell library'
    [ -x "$HOME/.dermux/android/dispatch.sh" ] && echo '[OK] dispatcher executable' || echo '[MISSING] dispatcher'
    [ -d "$HOME/.shortcuts" ] && echo '[OK] Termux:Widget scripts folder' || echo '[NOTE] Termux:Widget not installed/configured'
    grep -Eq '^[[:space:]]*allow-external-apps[[:space:]]*=[[:space:]]*true' "$HOME/.termux/termux.properties" 2>/dev/null && echo '[OK] allow-external-apps=true' || echo '[NOTE] External command bridge disabled';;
  *) echo 'Неизвестная команда. Открой DERMUX RU → Инструменты → Справка.'; exit 2;;
esac
