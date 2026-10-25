# DERMUX ULTRA v5.0

- Упрощены 47+ ярлыков: каждый файл вызывает одну понятную команду без лишнего диспетчера.
- Исправлен единый диспетчер: все кнопки Network/OSINT/Dev/Files направляются в явные функции, без `eval`.
- Добавлены Ping/Trace с подтверждением и ограниченным временем, Matrix Rain, Bash fallback и более аккуратное завершение Live HUD.
- Добавлены иконки фоновых задач; dynamic shortcuts сокращены до пяти фаворитов для совместимости с лимитами Android.
- Дополнен Widget Doctor, README и диагностика виджетов.

## v4.0 (base)


- Добавлены папки network/dev/files и более крупный command center.
- Добавлены local system tools, safe calculator, URL/Base64/JSON/Git/file utilities.
- Добавлены HTTP status, robots.txt, repo audit, health check, terminal live view.
- Добавлены one-shot background snapshots and backup tasks.
- Создана согласованная палитра иконок для ярлыков и wallpaper 1080×2400.
- Установщик запрашивает подтверждение перед package install/update и не запускает `pkg upgrade` автоматически.
- Внешние запросы требуют подтверждения; LAN discovery ограничен приватными IPv4 /24–/32.
