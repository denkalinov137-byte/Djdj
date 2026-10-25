# DERMUX ULTRA // by @osaoda · v5.0

Большой пакет для Termux без root: midnight-тема, Starship, командный центр, 6 категорий, 48 foreground-ярлыков, 55 PNG-иконок, 5 избранных dynamic shortcuts и 3 одноразовые фоновые задачи.

## Установка

Распакуй ZIP в Download и запусти в Termux (имя каталога может немного отличаться):

```bash
cd ~/storage/downloads/DERMUX_ULTRA_by_osaoda
bash setup.sh
```

Если `~/storage/downloads` отсутствует, один раз выполни `termux-setup-storage` и нажми `y` только когда появится вопрос. Не печатай следующую команду до возврата обычного приглашения.

**Важный пункт про источники пакетов:** новый установщик сначала покажет активные APT-репозитории и запросит подтверждение перед `pkg update/install`. В предыдущем логе встречались нестандартные хосты репозиториев. Не устанавливай пакеты из неизвестных источников; если сомневаешься, введи `n`, а затем выполни `repoaudit`. Оформление и скрипты всё равно будут скопированы.

## Быстрый старт

```bash
dermux
```

Другие команды: `dashboard`, `live`, `help`, `widgetdoctor`, `repoaudit`, `healthcheck`, `osint`, `matrix`, `pinghost`, `tracehost`.

## Категории ярлыков

- **SYSTEM** — Dashboard, батарея, Wi-Fi, RAM, storage, процессы, uptime, список пакетов и health check.
- **NETWORK** — локальные адреса/порты, ping, traceroute, HTTP status, Public IP и ограниченное LAN discovery.
- **OSINT** — DNS, WHOIS, RDAP, Certificate Transparency, HTTPS headers, TLS, robots.txt.
- **DEV** — SHA-256, JSON formatter, URL encode/decode, Base64, калькулятор только для арифметики, Python, Git status.
- **FILES** — заметки, поиск имени файла, подсчёт строк/слов/байтов, просмотр списка содержимого архива, backup.
- **TOOLS** — Command Map, Widget Doctor, Repo Audit, update packages, Matrix rain.
- **Background tasks** — одноразовый снимок системы, запись батареи, бэкап настроек; запускаются только по нажатию и не работают бесконечно.

## Виджеты на Samsung

Termux:Widget — отдельное Android-приложение. Его стандартный 2×2 виджет — список файлов и папок; bash-скрипт не может изменить нативный дизайн этого виджета на живую графическую панель. В этом пакете список сгруппирован по папкам, а отдельные команды имеют PNG-иконки.

1. Установи **Termux:Widget** и при необходимости **Termux:API** из источника, совместимого по подписи с Termux.
2. Открой Termux:Widget → `REFRESH`.
3. На домашнем экране зажми пустое место → **Виджеты** → **Termux:Widget** → добавь 2×2 список.
4. В виджете открой папку `system`, `network`, `osint`, `dev`, `files` или `tools`.
5. Для отдельных красивых ярлыков добавь `Termux shortcut` 1×1 и выбери скрипт. Иконка для `Dashboard.sh` должна называться `Dashboard.sh.png` внутри `~/.shortcuts/icons/`.
6. Для избранных ярлыков открой Termux:Widget → `CREATE SHORTCUTS`. Android ограничивает число dynamic shortcuts.
7. Если список пуст — запусти `widgetdoctor`, потом открой приложение Termux:Widget и ещё раз нажми `REFRESH`. Проверь, что приложение-дополнение действительно установлено и подписи совместимы.

Официальная инструкция: https://github.com/termux/termux-widget#readme

## Функции

`dashboard` — локальный снимок устройства; `live` — перерисовка панели раз в 4 секунды только в открытом терминале; `memory`, `storage`, `uptimeinfo`, `processes`, `apps`, `battery`, `wifi`; `netinfo`, `ports`; `dns`, `whoisdomain`, `rdap`, `ctlookup`, `headers`, `httpstatus`, `tls`, `robots`, `osint`; `publicip`; `pinghost`, `tracehost`, `landiscovery`; `hashfile`, `jsonpretty`, `urlencode`, `urldecode`, `b64encode`, `b64decode`, `calc`, `gitstatus`; `note`, `findfile`, `countlines`, `archiveinfo`, `backup`; `repoaudit`, `widgetdoctor`, `healthcheck`, `updatepackages`.

## Безопасность и приватность

- Внешние DNS/WHOIS/RDAP/CT/HTTPS/TLS/ping/trace запросы спрашивают подтверждение и отправляют данные указанного домена/хоста выбранному сервису. Сервис может видеть IP соединения.
- `publicip` спрашивает подтверждение перед запросом к `api.ipify.org`.
- LAN discovery ограничен частными RFC1918 IPv4-сетями /24–/32 и требует подтверждения. Используй только в своей/разрешённой сети.
- Калькулятор принимает только арифметические выражения и не выполняет код. `archiveinfo` только показывает список файлов, ничего не извлекает.
- Никаких сетевых запросов при старте терминала; нет эксплуатации уязвимостей, подбора паролей или постоянного фонового мониторинга.
- Проверен синтаксис shell-скриптов; реальную работу на конкретном Samsung нужно проверить после установки.
