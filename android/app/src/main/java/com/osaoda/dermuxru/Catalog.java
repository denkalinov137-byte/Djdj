package com.osaoda.dermuxru;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/** Русский каталог действий radial-меню. Все команды проходят через фиксированный shell allowlist. */
final class Catalog {
    static final int NONE = 0, DOMAIN = 1, HOST = 2, IP = 3, TEXT = 4, FILE = 5;

    static final class Action {
        final String id, title, glyph, description;
        final int inputType;
        final boolean confirm;
        Action(String id, String title, String glyph, String description, int inputType, boolean confirm) {
            this.id = id; this.title = title; this.glyph = glyph; this.description = description;
            this.inputType = inputType; this.confirm = confirm;
        }
    }

    static final class Category {
        final String id, title, glyph, subtitle;
        final List<Action> actions;
        Category(String id, String title, String glyph, String subtitle, Action... actions) {
            this.id=id; this.title=title; this.glyph=glyph; this.subtitle=subtitle;
            this.actions = new ArrayList<>(Arrays.asList(actions));
        }
    }

    private static Action a(String id, String title, String glyph, String description) {
        return new Action(id,title,glyph,description,NONE,false);
    }
    private static Action d(String id, String title, String glyph, String description) {
        return new Action(id,title,glyph,description,DOMAIN,true);
    }
    private static Action h(String id, String title, String glyph, String description) {
        return new Action(id,title,glyph,description,HOST,true);
    }
    private static Action ip(String id, String title, String glyph, String description) {
        return new Action(id,title,glyph,description,IP,true);
    }
    private static Action t(String id, String title, String glyph, String description) {
        return new Action(id,title,glyph,description,TEXT,false);
    }
    private static Action f(String id, String title, String glyph, String description) {
        return new Action(id,title,glyph,description,FILE,false);
    }

    static final List<Category> CATEGORIES = new ArrayList<>(Arrays.asList(
        new Category("system", "СИСТЕМА", "SYS", "Состояние телефона и Termux",
            a("dashboard", "Сводка", "HUD", "Сводка устройства и Termux"),
            a("battery", "Батарея", "BAT", "Состояние аккумулятора; нужен Termux:API"),
            a("wifi", "Wi‑Fi", "WIFI", "Информация Wi‑Fi; Android может скрывать SSID"),
            a("memory", "Память", "RAM", "Отчёт по оперативной памяти"),
            a("storage", "Хранилище", "DISK", "Использование хранилища Termux"),
            a("processes", "Процессы", "PROC", "Локальный список процессов"),
            a("uptime", "Аптайм", "TIME", "Время работы и load average"),
            a("snapshot", "Снимок", "LOG", "Сохранить локальный снимок системы")
        ),
        new Category("network", "СЕТЬ", "NET", "Диагностика соединения",
            a("netinfo", "Инфо сети", "IP", "Локальные адреса и маршрут"),
            a("ports", "Лок. порты", "PORT", "Только слушающие порты этого телефона"),
            d("dns", "DNS", "DNS", "Публичные DNS-записи домена"),
            h("ping", "Ping", "PING", "Ограниченная проверка доступности хоста"),
            h("trace", "Маршрут", "TR", "Traceroute с ограничением числа переходов"),
            d("httpstatus", "HTTP-код", "HTTP", "Статус HTTPS и время ответа"),
            a("publicip", "Публичный IP", "PUB", "Подтверждение перед обращением к сервису IP"),
            a("lan", "Лок. сеть", "LAN", "Обнаружение устройств только в частной сети /24–/32")
        ),
        new Category("osint", "OSINT", "OS", "Пассивные публичные источники · листай страницы",
            d("osint", "OSINT-обзор", "OS", "Общий обзор публичных DNS/WHOIS/CT-данных"),
            d("dns", "DNS-записи", "DNS", "A, AAAA, MX, NS, TXT, CAA, DMARC"),
            d("whois", "WHOIS", "WHO", "Публичные регистрационные сведения домена"),
            d("rdap", "RDAP", "RDP", "Регистрационные данные через RDAP"),
            d("ct", "CT-имена", "CT", "Публичные имена из Certificate Transparency"),
            d("headers", "HTTPS-загол.", "HDR", "HTTP-заголовки сайта"),
            d("tls", "TLS-сертификат", "TLS", "Издатель, срок и SHA-256 сертификата"),
            d("robots", "robots.txt", "ROB", "Получить публичный robots.txt"),
            d("emailsec", "SPF / DMARC", "MAIL", "Публичные TXT-политики доменной почты"),
            d("sectxt", "security.txt", "SEC", "Проверить публичный security.txt"),
            d("sitemap", "sitemap.xml", "MAP", "Проверить публичную карту сайта"),
            ip("iprdap", "RDAP IP", "IP", "Публичные регистрационные данные IPv4"),
            d("txtrecords", "TXT-записи", "TXT", "Текстовые DNS-записи домена"),
            d("webtitle", "Заголовок", "HTML", "Прочитать заголовок открытой главной страницы"),
            d("redirects", "Редиректы", "RED", "Проверить HTTPS-цепочку перенаправлений"),
            d("faviconhash", "Хэш favicon", "HASH", "Скачать публичный favicon и вычислить его хэши")
        ),
        new Category("web", "WEB / ДОМЕН", "WEB", "Публичная проверка выбранного сайта",
            d("headers", "Заголовки", "HDR", "HTTPS-заголовки ответа"),
            d("tls", "TLS", "TLS", "Сведения сертификата HTTPS"),
            d("httpstatus", "HTTP статус", "HTTP", "Код ответа, IP и время соединения"),
            d("sectxt", "security.txt", "SEC", "Публичный контакт для security reports"),
            d("sitemap", "Карта сайта", "MAP", "Проверить sitemap.xml"),
            d("robots", "robots.txt", "ROB", "Прочитать robots.txt"),
            d("webtitle", "HTML title", "HTML", "Получить только заголовок HTML-страницы"),
            d("redirects", "Редиректы", "RED", "Цепочка HTTPS-ответов")
        ),
        new Category("dev", "РАЗРАБОТКА", "DEV", "Форматирование и работа с данными",
            f("jsonpretty", "JSON", "JSON", "Форматировать локальный JSON-файл"),
            t("urlencode", "URL-код", "ENC", "Закодировать строку для URL"),
            t("urldecode", "URL-декод", "DEC", "Декодировать URL-строку"),
            t("b64encode", "Base64 +", "B64", "Закодировать текст в Base64"),
            t("b64decode", "Base64 −", "B64", "Декодировать Base64-текст"),
            f("hash", "SHA-256", "SHA", "Хэш локального файла без его изменения"),
            a("gitstatus", "Git status", "GIT", "Состояние текущего Git-репозитория"),
            t("calc", "Калькулятор", "CALC", "Безопасная арифметика; код не исполняется")
        ),
        new Category("files", "ФАЙЛЫ", "FILE", "Локальные файлы · ничего не удаляется автоматически",
            t("find", "Найти файл", "FIND", "Найти файл по части имени в домашней папке"),
            f("count", "Подсчёт", "CNT", "Число строк, слов и байтов локального файла"),
            f("archive", "Архив-info", "ZIP", "Только список содержимого архива; без распаковки"),
            t("note", "Заметка", "NOTE", "Добавить строку в локальный файл заметок"),
            a("backup", "Бэкап", "BAK", "Создать резервную копию конфигураций"),
            a("listfiles", "Файлы HOME", "DIR", "Показать список файлов в домашней папке"),
            a("storage", "Размер HOME", "SIZE", "Размер каталогов домашней папки"),
            a("snapshot", "Снимок", "LOG", "Сохранить локальный системный отчёт")
        ),
        new Category("tools", "ИНСТРУМЕНТЫ", "TOOL", "Помощь, обслуживание и диагностика",
            a("live", "Live-панель", "LIVE", "Обновляемая панель внутри терминала; Ctrl+C для выхода"),
            a("healthcheck", "Проверка", "OK", "Наличие команд и приложений Termux"),
            a("repoaudit", "Репозитории", "APT", "Показать источники пакетов без изменений"),
            a("widgetdoctor", "Widget Doctor", "FIX", "Проверить каталоги и обновить Termux:Widget"),
            a("matrix", "Matrix rain", "01", "Декоративная анимация в терминале"),
            a("help", "Справка", "HELP", "Список команд и подсказки на русском"),
            a("python", "Python shell", "PY", "Открыть интерактивную консоль Python"),
            a("update", "Обновить пакеты", "UP", "Перед изменениями пакетов будет запрос")
        ),
        new Category("setup", "НАСТРОЙКИ", "SET", "Подключение Android-приложения к Termux",
            a("connectcheck", "Связь Termux", "LINK", "Показать инструкцию и проверить подключение"),
            a("widgetadd", "Добавить виджет", "+", "Запросить закрепление виджета на домашнем экране"),
            a("permissions", "Разрешения", "KEY", "Как разрешить выполнение команд через Termux"),
            a("repoaudit", "Источники APT", "APT", "Проверить сторонние источники пакетов"),
            a("healthcheck", "Диагностика", "CHK", "Проверить установленные инструменты"),
            a("backup", "Резервная копия", "BAK", "Сохранить копию конфигураций"),
            a("update", "Обновления", "UP", "Пакеты обновляются только после подтверждения"),
            a("help", "Справка", "HELP", "Открыть справку DERMUX")
        )
    ));

    private Catalog() {}
}
