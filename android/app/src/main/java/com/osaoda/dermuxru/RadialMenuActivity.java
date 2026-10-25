package com.osaoda.dermuxru;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public final class RadialMenuActivity extends Activity implements RadialWheelView.Listener {
    private static final String TERMUX_PACKAGE = "com.termux";
    private static final String TERMUX_HOME = "/data/data/com.termux/files/home";
    private static final String TERMUX_BASH = "/data/data/com.termux/files/usr/bin/bash";
    private static final String DISPATCH = TERMUX_HOME + "/.dermux/android/dispatch.sh";
    private static final int PAGE_SIZE = 8;

    private LinearLayout root;
    private TextView headline, subtitle, pageInfo, widgetButton;
    private Button backButton, nextButton;
    private RadialWheelView wheel;
    private Catalog.Category currentCategory = null;
    private int page = 0;
    private boolean english = false;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        Window window = getWindow();
        window.setStatusBarColor(Color.rgb(7,11,19));
        window.setNavigationBarColor(Color.rgb(7,11,19));
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        english = getPreferences(MODE_PRIVATE).getBoolean("language_en", false);
        buildUi();
        showCategories();
        root.postDelayed(this::offerPinOnFirstLaunch, 650);
    }

    @Override protected void onResume() {
        super.onResume();
        updateWidgetButton();
    }

    private int dp(float x) { return (int)(x * getResources().getDisplayMetrics().density + 0.5f); }

    private GradientDrawable round(int fill, int stroke, int radiusDp) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(fill);
        d.setCornerRadius(dp(radiusDp));
        d.setStroke(dp(1), stroke);
        return d;
    }

    private TextView text(String s, int size, int color, boolean bold) {
        TextView t = new TextView(this);
        t.setText(s); t.setTextSize(size); t.setTextColor(color);
        t.setTypeface(Typeface.create(bold ? "sans-serif-black" : "sans-serif", bold ? Typeface.BOLD : Typeface.NORMAL));
        return t;
    }

    private Button button(String label, boolean primary) {
        Button b = new Button(this);
        b.setText(label); b.setAllCaps(false); b.setTextSize(12); b.setMinHeight(dp(42));
        b.setPadding(dp(10), 0, dp(10), 0);
        b.setTextColor(primary ? Color.rgb(7,11,19) : Color.rgb(213,231,246));
        b.setBackground(round(primary ? 0xFF66F5FF : 0xFF111927, primary ? 0xFF66F5FF : 0xFF315067, 14));
        return b;
    }

    private void buildUi() {
        root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(dp(12), dp(10), dp(12), dp(8));
        root.setBackgroundColor(0xFF070B13);
        setContentView(root);

        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        top.setOrientation(LinearLayout.HORIZONTAL);
        TextView logo = text("D/", 30, 0xFF66F5FF, true);
        logo.setGravity(Gravity.CENTER);
        logo.setBackground(round(0xFF101D2C, 0xFF315B6D, 17));
        LinearLayout.LayoutParams lpLogo = new LinearLayout.LayoutParams(dp(54), dp(54));
        top.addView(logo, lpLogo);

        LinearLayout titles = new LinearLayout(this);
        titles.setOrientation(LinearLayout.VERTICAL);
        titles.setPadding(dp(10), 0, dp(6), 0);
        headline = text("DERMUX RU", 21, 0xFF66F5FF, true);
        subtitle = text(english ? "COMMAND WHEEL · BY @OSAODA" : "КРУГОВОЙ ПУЛЬТ · BY @OSAODA", 9, 0xFFC59BFF, true);
        subtitle.setOnClickListener(v -> chooseLanguage());
        subtitle.setOnLongClickListener(v -> { chooseLanguage(); return true; });
        titles.addView(headline);
        titles.addView(subtitle);
        top.addView(titles, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        widgetButton = text("＋\nВИДЖЕТ", 10, 0xFF64FFDA, true);
        widgetButton.setGravity(Gravity.CENTER);
        widgetButton.setPadding(dp(8), dp(4), dp(8), dp(4));
        widgetButton.setBackground(round(0xFF101D2C, 0xFF315B6D, 14));
        widgetButton.setOnClickListener(v -> requestPinWidget(true));
        top.addView(widgetButton, new LinearLayout.LayoutParams(dp(76), dp(50)));
        root.addView(top, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        TextView status = text(english ? "●  LANGUAGE / ЯЗЫК     •     TAP TITLE TO CHANGE" : "●  РУССКИЙ РЕЖИМ     •     НАЖМИ НА ЗАГОЛОВОК ДЛЯ ЯЗЫКА", 9, 0xFF8BA4BD, true);
        status.setPadding(dp(7), dp(7), dp(4), dp(2));
        root.addView(status);

        wheel = new RadialWheelView(this);
        wheel.setListener(this);
        LinearLayout.LayoutParams wheelParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f);
        wheelParams.topMargin = dp(4);
        wheelParams.bottomMargin = dp(4);
        root.addView(wheel, wheelParams);

        LinearLayout nav = new LinearLayout(this);
        nav.setOrientation(LinearLayout.HORIZONTAL);
        nav.setGravity(Gravity.CENTER_VERTICAL);
        backButton = button("◀  Назад", false);
        backButton.setOnClickListener(v -> {
            if (currentCategory != null) showCategories(); else showSetupInfo();
        });
        pageInfo = text("КАТЕГОРИИ", 10, 0xFF8FA8C0, true);
        pageInfo.setGravity(Gravity.CENTER);
        nextButton = button("Ещё  ▶", false);
        nextButton.setOnClickListener(v -> nextPage());
        nav.addView(backButton, new LinearLayout.LayoutParams(0, dp(42), 1f));
        nav.addView(pageInfo, new LinearLayout.LayoutParams(0, dp(42), 1.1f));
        nav.addView(nextButton, new LinearLayout.LayoutParams(0, dp(42), 1f));
        root.addView(nav);

        TextView foot = text("ВНЕШНИЕ ЗАПРОСЫ ПОДТВЕРЖДАЮТСЯ В TERMUX  ·  ТЕСТЫ СЕТИ — ТОЛЬКО С РАЗРЕШЕНИЕМ", 8, 0xFF657B93, false);
        foot.setGravity(Gravity.CENTER);
        foot.setPadding(dp(5), dp(8), dp(5), 0);
        root.addView(foot);
    }

    private void chooseLanguage() {
        String[] langs = {"Русский", "English"};
        new AlertDialog.Builder(this).setTitle(english ? "Language / Язык" : "Язык / Language")
            .setSingleChoiceItems(langs, english ? 1 : 0, (dialog, which) -> {
                english = which == 1;
                getPreferences(MODE_PRIVATE).edit().putBoolean("language_en", english).apply();
                dialog.dismiss();
                refreshLanguage();
            }).setNegativeButton(english ? "Cancel" : "Отмена", null).show();
    }

    private String localized(String ru, String en) { return english ? en : ru; }

    private void refreshLanguage() {
        subtitle.setText(localized("КРУГОВОЙ ПУЛЬТ · BY @OSAODA", "COMMAND WHEEL · BY @OSAODA"));
        showCategories();
        Toast.makeText(this, localized("Язык интерфейса изменён", "Interface language changed"), Toast.LENGTH_SHORT).show();
    }

    private void updateWidgetButton() {
        try {
            int count = AppWidgetManager.getInstance(this).getAppWidgetIds(new ComponentName(this, DerMuxWidgetProvider.class)).length;
            widgetButton.setText(count > 0 ? "✓\nВИДЖЕТ" : "＋\nВИДЖЕТ");
        } catch (Exception ignored) { }
    }

    private void offerPinOnFirstLaunch() {
        if (isFinishing()) return;
        boolean offered = getPreferences(MODE_PRIVATE).getBoolean("pin_prompted", false);
        if (offered) return;
        int count = AppWidgetManager.getInstance(this).getAppWidgetIds(new ComponentName(this, DerMuxWidgetProvider.class)).length;
        if (count == 0) requestPinWidget(false);
    }

    private void requestPinWidget(boolean userInitiated) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            new AlertDialog.Builder(this).setTitle("Добавление виджета")
                .setMessage("Зажми пустое место на главном экране → Виджеты → DERMUX — КОЛЕСО КОМАНД.")
                .setPositiveButton("Понятно", null).show();
            return;
        }
        AppWidgetManager manager = AppWidgetManager.getInstance(this);
        ComponentName provider = new ComponentName(this, DerMuxWidgetProvider.class);
        if (manager.getAppWidgetIds(provider).length > 0) {
            Toast.makeText(this, "Виджет DERMUX уже добавлен или доступен в списке виджетов.", Toast.LENGTH_LONG).show();
            updateWidgetButton();
            return;
        }
        if (!manager.isRequestPinAppWidgetSupported()) {
            new AlertDialog.Builder(this).setTitle("Виджет DERMUX")
                .setMessage("Этот лаунчер не поддерживает быстрый запрос на закрепление. Зажми пустое место на домашнем экране → Виджеты → DERMUX — КОЛЕСО КОМАНД.")
                .setPositiveButton("ОК", null).show();
            return;
        }
        try {
            boolean requested = manager.requestPinAppWidget(provider, null, null);
            if (requested) {
                getPreferences(MODE_PRIVATE).edit().putBoolean("pin_prompted", true).apply();
                Toast.makeText(this, "Подтверди добавление в диалоге Android.", Toast.LENGTH_LONG).show();
            } else if (userInitiated) {
                Toast.makeText(this, "Лаунчер не принял запрос. Добавь виджет через список Виджеты.", Toast.LENGTH_LONG).show();
            }
        } catch (Exception ex) {
            Toast.makeText(this, "Добавь DERMUX через домашний экран → Виджеты.", Toast.LENGTH_LONG).show();
        }
    }

    private List<RadialWheelView.Item> itemsForCategories() {
        List<RadialWheelView.Item> result = new ArrayList<>();
        for (Catalog.Category c : Catalog.CATEGORIES) result.add(new RadialWheelView.Item(c.title, c.glyph));
        return result;
    }

    private List<RadialWheelView.Item> itemsForCategoriesLocalized() {
        List<RadialWheelView.Item> result = new ArrayList<>();
        String[] ru = {"СИСТЕМА","СЕТЬ","OSINT","WEB / ДОМЕН","РАЗРАБОТКА","ФАЙЛЫ","ИНСТРУМЕНТЫ","НАСТРОЙКИ"};
        String[] en = {"SYSTEM","NETWORK","OSINT","WEB / DOMAIN","DEVELOPMENT","FILES","TOOLS","SETTINGS"};
        for (int i=0; i<Catalog.CATEGORIES.size(); i++) { Catalog.Category c = Catalog.CATEGORIES.get(i); result.add(new RadialWheelView.Item(english ? en[i] : ru[i], c.glyph)); }
        return result;
    }

    private void showCategories() {
        currentCategory = null; page = 0;
        headline.setText("DERMUX");
        subtitle.setText(localized("ВЫБЕРИ СЕКТОР · BY @OSAODA", "CHOOSE A SECTOR · BY @OSAODA"));
        wheel.setItems(itemsForCategoriesLocalized(), "D/", localized("ВЫБОР", "SELECT"));
        pageInfo.setText(localized("8 КАТЕГОРИЙ", "8 CATEGORIES"));
        backButton.setText(localized("ⓘ  Справка", "ⓘ  Help"));
        nextButton.setText(localized("Виджет  ↗", "Widget  ↗"));
        backButton.setOnClickListener(v -> showSetupInfo());
        nextButton.setOnClickListener(v -> requestPinWidget(true));
    }

    private void showCategory(Catalog.Category category) {
        currentCategory = category; page = 0;
        displayCurrentPage();
    }

    private void displayCurrentPage() {
        if (currentCategory == null) { showCategories(); return; }
        headline.setText("DERMUX  /  " + categoryTitle(currentCategory));
        subtitle.setText((english ? "SELECT AN ACTION · BY @OSAODA" : currentCategory.subtitle.toUpperCase(Locale.ROOT)));
        List<RadialWheelView.Item> list = new ArrayList<>();
        int start = page * PAGE_SIZE;
        int end = Math.min(start + PAGE_SIZE, currentCategory.actions.size());
        for (int i=start; i<end; i++) {
            Catalog.Action a = currentCategory.actions.get(i);
            list.add(new RadialWheelView.Item(actionTitle(a), a.glyph));
        }
        wheel.setItems(list, "D/", localized("НАЗАД", "BACK"));
        pageInfo.setText((english ? "PAGE " : "ЛИСТ ") + (page + 1) + "/" + Math.max(1, (currentCategory.actions.size() + PAGE_SIZE - 1)/PAGE_SIZE));
        backButton.setText(localized("◀  Категории", "◀  Categories"));
        backButton.setOnClickListener(v -> showCategories());
        boolean more = (page + 1) * PAGE_SIZE < currentCategory.actions.size();
        nextButton.setText(more ? localized("Далее  ▶", "Next  ▶") : localized("Виджет  ↗", "Widget  ↗"));
        nextButton.setOnClickListener(v -> { if (more) nextPage(); else requestPinWidget(true); });
    }

    private String categoryTitle(Catalog.Category c) {
        if (!english) return c.title;
        switch (c.id) {
            case "system": return "SYSTEM"; case "network": return "NETWORK"; case "osint": return "OSINT";
            case "web": return "WEB / DOMAIN"; case "dev": return "DEVELOPMENT"; case "files": return "FILES";
            case "tools": return "TOOLS"; case "setup": return "SETTINGS"; default: return c.title;
        }
    }

    private String actionTitle(Catalog.Action a) {
        if (!english) return a.title;
        String[][] map = {
            {"Сводка","Overview"},{"Батарея","Battery"},{"Wi‑Fi","Wi-Fi"},{"Память","Memory"},{"Хранилище","Storage"},{"Процессы","Processes"},{"Аптайм","Uptime"},{"Снимок","Snapshot"},
            {"Инфо сети","Network info"},{"Лок. порты","Local ports"},{"DNS-записи","DNS records"},{"DNS","DNS lookup"},{"Ping","Ping"},{"Маршрут","Traceroute"},{"HTTP-код","HTTP status"},{"Публичный IP","Public IP"},{"Лок. сеть","Local network"},
            {"OSINT-обзор","OSINT overview"},{"WHOIS","WHOIS"},{"RDAP","RDAP"},{"CT-имена","CT subdomains"},{"HTTPS-загол.","HTTPS headers"},{"TLS-сертификат","TLS certificate"},{"robots.txt","robots.txt"},{"SPF / DMARC","SPF / DMARC"},{"security.txt","security.txt"},
            {"Справка","Help"},{"Связь с Termux","Termux connection"},{"Проверка связи","Connection test"},{"Настройки","Settings"},{"Назад","Back"}
        };
        for (String[] pair : map) if (pair[0].equals(a.title)) return pair[1];
        return a.title;
    }

    private void nextPage() {
        if (currentCategory == null) {
            showSetupInfo();
            return;
        }
        int count = (currentCategory.actions.size() + PAGE_SIZE - 1)/PAGE_SIZE;
        if (page + 1 < count) { page++; displayCurrentPage(); }
        else Toast.makeText(this, "Это последний лист.", Toast.LENGTH_SHORT).show();
    }

    @Override public void onItemSelected(int index) {
        if (currentCategory == null) {
            if (index >= Catalog.CATEGORIES.size()) return;
            showCategory(Catalog.CATEGORIES.get(index));
            return;
        }
        int pos = page * PAGE_SIZE + index;
        if (pos < 0 || pos >= currentCategory.actions.size()) {
            Toast.makeText(this, "Этот сектор пуст.", Toast.LENGTH_SHORT).show();
            return;
        }
        chooseAction(currentCategory.actions.get(pos));
    }

    @Override public void onCenterTap() {
        if (currentCategory != null) showCategories();
        else showSetupInfo();
    }

    private void chooseAction(Catalog.Action action) {
        switch (action.id) {
            case "widgetadd": requestPinWidget(true); return;
            case "permissions": showTermuxConnectInfo(); return;
            case "connectcheck":
                new AlertDialog.Builder(this).setTitle("Связь с Termux")
                    .setMessage("Запустить локальную диагностику мостика DERMUX? Она проверит библиотеку, dispatcher и allow-external-apps; сетевые запросы не выполняются.")
                    .setNegativeButton("Инструкция", (dlg, which) -> showTermuxConnectInfo())
                    .setPositiveButton("Проверить", (dlg, which) -> runTermux(new Catalog.Action("selfcheck", "Проверка связи", "CHK", "Локальная проверка", Catalog.NONE, false), null))
                    .setNeutralButton("Отмена", null).show();
                return;
            default: break;
        }
        if (action.inputType == Catalog.NONE) {
            if ("publicip".equals(action.id)) {
                new AlertDialog.Builder(this).setTitle("Публичный IP")
                    .setMessage("DERMUX откроет Termux и спросит подтверждение перед обращением к стороннему сервису IP. Сервис увидит IP твоего интернет-соединения. Продолжить?")
                    .setNegativeButton("Отмена", null).setPositiveButton("Продолжить", (d,w) -> runTermux(action, null)).show();
            } else {
                new AlertDialog.Builder(this).setTitle(action.title)
                    .setMessage(action.description + "\n\nЗапустить в Termux?")
                    .setNegativeButton("Отмена", null).setPositiveButton("Запустить", (d,w) -> runTermux(action, null)).show();
            }
            return;
        }
        promptForInput(action);
    }

    private void promptForInput(Catalog.Action action) {
        final EditText input = new EditText(this);
        input.setSingleLine(action.inputType != Catalog.TEXT);
        input.setTextColor(0xFFF2F7FF);
        input.setHintTextColor(0xFF6F8298);
        input.setHint(inputHint(action.inputType));
        input.setImeOptions(EditorInfo.IME_ACTION_DONE);
        input.setPadding(dp(12), dp(12), dp(12), dp(12));
        input.setBackground(round(0xFF111927, 0xFF315067, 12));
        LinearLayout wrap = new LinearLayout(this);
        wrap.setPadding(dp(22), dp(8), dp(22), 0);
        wrap.addView(input, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        AlertDialog dialog = new AlertDialog.Builder(this)
            .setTitle(action.title)
            .setMessage(action.description + "\n\n" + inputHint(action.inputType))
            .setView(wrap)
            .setNegativeButton("Отмена", null)
            .setPositiveButton("Продолжить", null)
            .create();
        dialog.setOnShowListener(v -> {
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(btn -> {
                String value = input.getText().toString().trim();
                if (value.isEmpty()) { input.setError("Поле не должно быть пустым"); return; }
                value = normalize(value, action.inputType);
                String error = validate(value, action.inputType);
                if (error != null) { input.setError(error); return; }
                dialog.dismiss();
                runTermux(action, value);
            });
        });
        dialog.show();
    }

    private String inputHint(int type) {
        switch (type) {
            case Catalog.DOMAIN: return "Домен, например example.com";
            case Catalog.HOST: return "Домен или IPv4, например example.com";
            case Catalog.IP: return "IPv4-адрес, например 203.0.113.10";
            case Catalog.FILE: return "Путь к локальному файлу, например ~/storage/downloads/data.json";
            default: return "Текст или выражение";
        }
    }

    private String normalize(String value, int type) {
        if (type == Catalog.DOMAIN || type == Catalog.HOST || type == Catalog.IP) {
            value = value.replaceFirst("(?i)^https?://", "");
            value = value.split("/", 2)[0];
            if (type != Catalog.IP) value = value.replaceFirst(":\\d+$", "");
            value = value.replaceAll("\\.$", "");
        }
        return value;
    }

    private String validate(String value, int type) {
        if (type == Catalog.TEXT && value.length() > 4000) return "Максимум 4000 символов";
        if (type == Catalog.FILE && value.length() > 350) return "Путь слишком длинный";
        if (type == Catalog.DOMAIN || type == Catalog.HOST) {
            String domain = "(?i)^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,63}$";
            String ipv4 = "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$";
            if (!value.matches(domain) && !(type == Catalog.HOST && value.matches(ipv4))) return "Введи домен без пробелов и URL-пути";
            if (value.contains("..")) return "Домен содержит недопустимую последовательность";
        }
        if (type == Catalog.IP) {
            if (!value.matches("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$")) return "Нужен IPv4-адрес";
            String[] octets = value.split("\\.");
            for (String o : octets) try { int n = Integer.parseInt(o); if(n<0||n>255) return "Неверный октет IPv4"; } catch(Exception ex) { return "Неверный IPv4"; }
        }
        return null;
    }

    private void runTermux(Catalog.Action action, String value) {
        try {
            if (Build.VERSION.SDK_INT >= 33) {
                getPackageManager().getPackageInfo(TERMUX_PACKAGE, PackageManager.PackageInfoFlags.of(0));
            } else {
                getPackageManager().getPackageInfo(TERMUX_PACKAGE, 0);
            }
        } catch (Exception ex) {
            showTermuxConnectInfo(); return;
        }
        Intent intent = new Intent();
        intent.setClassName(TERMUX_PACKAGE, "com.termux.app.RunCommandService");
        intent.setAction("com.termux.RUN_COMMAND");
        intent.putExtra("com.termux.RUN_COMMAND_PATH", TERMUX_BASH);
        if (value == null) intent.putExtra("com.termux.RUN_COMMAND_ARGUMENTS", new String[]{DISPATCH, action.id});
        else intent.putExtra("com.termux.RUN_COMMAND_ARGUMENTS", new String[]{DISPATCH, action.id, value});
        intent.putExtra("com.termux.RUN_COMMAND_WORKDIR", TERMUX_HOME);
        intent.putExtra("com.termux.RUN_COMMAND_BACKGROUND", false);
        intent.putExtra("com.termux.RUN_COMMAND_SESSION_ACTION", "0");
        try {
            startService(intent);
            Toast.makeText(this, "Команда передана в Termux: " + action.title, Toast.LENGTH_LONG).show();
        } catch (SecurityException ex) {
            new AlertDialog.Builder(this).setTitle("Нет разрешения")
                .setMessage("Для связи нужно включить allow-external-apps=true в ~/.termux/termux.properties и дать приложению DERMUX разрешение «Выполнять команды в Termux». Подробности — в инструкции.")
                .setNegativeButton("Позже", null)
                .setPositiveButton("Настройки DERMUX", (d,w) -> openAppSettings())
                .show();
        } catch (Exception ex) {
            new AlertDialog.Builder(this).setTitle("Не удалось открыть Termux")
                .setMessage("Проверь, что Termux установлен из совместимого источника, обновлён и разрешает запуск внешних команд.\n\n" + ex.getClass().getSimpleName())
                .setPositiveButton("ОК", null).show();
        }
    }

    private void openAppSettings() {
        try { startActivity(new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + getPackageName()))); }
        catch (Exception ignored) { }
    }

    private void showSetupInfo() {
        new AlertDialog.Builder(this).setTitle("DERMUX RU · краткая справка")
            .setMessage("КАК ПОЛЬЗОВАТЬСЯ\n1. Коснись одного из восьми секторов.\n2. Внутри категории выбери команду.\n3. Для домена/файла введи значение.\n4. В центре круга — возврат к категориям.\n5. Если команд больше восьми, используй «Далее».\n\nПассивный OSINT — публичные данные. Делай проверки только для разрешённых доменов. Сетевое обнаружение ограничено частными небольшими диапазонами.")
            .setPositiveButton("Понятно", null).setNeutralButton("Связь с Termux", (d,w) -> showTermuxConnectInfo()).show();
    }

    private void showTermuxConnectInfo() {
        new AlertDialog.Builder(this).setTitle("Подключение к Termux")
            .setMessage("Нужно выполнить три шага:\n\n1. В Termux установи Termux (пакет приложения должен называться com.termux).\n2. В DERMUX RU → Информация о приложении → Разрешения → Дополнительные разрешения выдай «Выполнять команды в Termux».\n3. В Termux открой ~/.termux/termux.properties и разреши allow-external-apps = true. Установщик DERMUX может добавить эту строку после твоего согласия.\n\nЗатем нажми «Открыть колесо» и запусти любую локальную команду. Для интернет-проверок Termux дополнительно спросит подтверждение.")
            .setPositiveButton("Настройки DERMUX", (d,w) -> openAppSettings())
            .setNegativeButton("Закрыть", null).show();
    }
}
