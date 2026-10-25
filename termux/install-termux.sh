#!/data/data/com.termux/files/usr/bin/bash
# DERMUX RU — установка Termux-компонентов и мостика Android-приложения.
set -u
if [ -z "${PREFIX:-}" ] || [ ! -d "${PREFIX:-/nonexistent}" ] || ! command -v pkg >/dev/null 2>&1; then
  echo 'ОШИБКА: запусти этот файл из приложения Termux.'; exit 1
fi
HERE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BUNDLE="$HERE/DERMUX_ULTRA_by_osaoda"
DISPATCH_SOURCE="$HERE/android/dispatch.sh"
[ -f "$BUNDLE/setup.sh" ] || { echo 'Не найдена базовая папка DERMUX_ULTRA_by_osaoda.'; exit 2; }
[ -f "$DISPATCH_SOURCE" ] || { echo 'Не найден bridge dispatch.sh.'; exit 2; }

echo '╭────────────────────────────────────────────╮'
echo '│ DERMUX RU · BY @OSAODA                    │'
echo '│ Установка русского radial-пульта          │'
echo '╰────────────────────────────────────────────╯'
echo 'Сначала запустится базовая настройка DERMUX с проверкой источников пакетов.'
read -r -p 'Продолжить? [y/N] ' go || go=n
case "$go" in y|Y|yes|YES) ;; *) echo 'Отменено.'; exit 0;; esac
bash "$BUNDLE/setup.sh" || { echo 'Базовая установка завершилась с ошибкой. Проверь лог выше.'; exit 1; }

mkdir -p "$HOME/.dermux/android"
cp "$DISPATCH_SOURCE" "$HOME/.dermux/android/dispatch.sh"
chmod 700 "$HOME/.dermux" "$HOME/.dermux/android" "$HOME/.dermux/android/dispatch.sh"

STAMP="$(date +%Y%m%d-%H%M%S)"
PROPS="$HOME/.termux/termux.properties"
mkdir -p "$HOME/.termux"
[ -f "$PROPS" ] || : > "$PROPS"
cp -p "$PROPS" "$PROPS.dermux-ru-backup-$STAMP" 2>/dev/null || true
cat <<'NOTICE'

ВАЖНО ДЛЯ СВЯЗИ С ОТДЕЛЬНЫМ ANDROID-ПРИЛОЖЕНИЕМ:
allow-external-apps=true позволяет приложениям с выданным Android-разрешением
запускать команды внутри Termux. DERMUX RU просит такое разрешение отдельно.
Не включай это, если не собираешься устанавливать собственное приложение DERMUX.
NOTICE
read -r -p 'Включить allow-external-apps=true для DERMUX RU? [y/N] ' allow || allow=n
case "$allow" in
  y|Y|yes|YES)
    tmp="$PROPS.dermux-tmp"
    awk '!/^[[:space:]]*allow-external-apps[[:space:]]*=/' "$PROPS" > "$tmp" 2>/dev/null || : > "$tmp"
    printf '\n# DERMUX RU bridge — enabled by user consent\nallow-external-apps = true\n' >> "$tmp"
    mv "$tmp" "$PROPS"
    echo '[OK] allow-external-apps=true включён.';;
  *) echo '[NOTE] Не включено. Внешний пульт не сможет запускать команды, пока ты не разрешишь это вручную.';;
esac
command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings >/dev/null 2>&1 || true
printf '\nУстановка Termux-части закончена.\n'
printf 'Проверь: bash ~/.dermux/android/dispatch.sh selfcheck\n'
printf 'Затем собери Android-проект из папки android/ по README_RU.md.\n'
printf 'В Android выдавай DERMUX RU разрешение «Выполнять команды в Termux».\n'
