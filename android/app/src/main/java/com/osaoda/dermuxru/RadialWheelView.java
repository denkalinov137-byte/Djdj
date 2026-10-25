package com.osaoda.dermuxru;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.view.MotionEvent;
import android.view.View;

import java.util.ArrayList;
import java.util.List;

/** CS-style radial wheel: восемь секторов, центральная кнопка возврата, русские подписи. */
public final class RadialWheelView extends View {
    public interface Listener {
        void onItemSelected(int index);
        void onCenterTap();
    }
    public static final class Item {
        public final String title, glyph;
        public Item(String title, String glyph) { this.title = title; this.glyph = glyph; }
    }

    private final Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final List<Item> items = new ArrayList<>();
    private Listener listener;
    private String centerTitle = "D/", centerSubtitle = "КОЛЕСО";
    private int selected = -1;

    private final int[] sectorColors = {
        0xFF102236, 0xFF111A2B, 0xFF102A30, 0xFF17182B,
        0xFF122638, 0xFF101C2A, 0xFF14252B, 0xFF171B31
    };

    public RadialWheelView(Context context) {
        super(context);
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        setFocusable(true);
        setContentDescription("Круговое меню DERMUX. Коснитесь сектора для выбора.");
    }

    public void setListener(Listener listener) { this.listener = listener; }

    public void setItems(List<Item> newItems, String centerTitle, String centerSubtitle) {
        items.clear();
        if (newItems != null) items.addAll(newItems);
        this.centerTitle = centerTitle == null ? "D/" : centerTitle;
        this.centerSubtitle = centerSubtitle == null ? "КОЛЕСО" : centerSubtitle;
        selected = -1;
        invalidate();
    }

    private float dp(float v) { return v * getResources().getDisplayMetrics().density; }

    @Override protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        float w = getWidth(), h = getHeight();
        canvas.drawColor(0xFF070B13);
        float min = Math.min(w, h);
        float r = min * 0.475f;
        float cx = w / 2f, cy = h / 2f;

        p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(dp(1)); p.setColor(0xFF183244);
        canvas.drawCircle(cx, cy, r, p);
        p.setStrokeWidth(dp(1)); p.setColor(0x223BF3FF); canvas.drawCircle(cx, cy, r * .86f, p);

        for (int i = 0; i < 8; i++) {
            float start = -112.5f + i * 45f;
            Path sector = new Path();
            sector.moveTo(cx, cy);
            RectF oval = new RectF(cx-r, cy-r, cx+r, cy+r);
            sector.arcTo(oval, start, 45f);
            sector.close();
            p.setStyle(Paint.Style.FILL);
            int base = sectorColors[i];
            if (i == selected) base = 0xFF1C4554;
            canvas.drawPath(sector, pWithColor(base));
            p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(dp(1)); p.setColor(0xFF254052);
            canvas.drawPath(sector, p);
        }

        // Inner ring and radial separators make the wedge boundaries readable on phone screens.
        p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(dp(1)); p.setColor(0xFF2B5263);
        canvas.drawCircle(cx, cy, r * .34f, p);
        canvas.drawCircle(cx, cy, r * .48f, p);

        float nodeR = Math.max(dp(28), r * .175f);
        float nodeOrbit = r * .665f;
        for (int i = 0; i < 8; i++) {
            double angle = Math.toRadians(-90 + 45 * i);
            float nx = cx + (float)Math.cos(angle) * nodeOrbit;
            float ny = cy + (float)Math.sin(angle) * nodeOrbit;
            p.setStyle(Paint.Style.FILL);
            p.setColor(i < items.size() ? 0xFF14263A : 0xFF0B111D);
            canvas.drawCircle(nx, ny, nodeR, p);
            p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(i == selected ? dp(2.5f) : dp(1.1f));
            p.setColor(i == selected ? 0xFF66F5FF : (i < items.size() ? 0xFF3C8390 : 0xFF1D2A38));
            canvas.drawCircle(nx, ny, nodeR, p);
            if (i >= items.size()) continue;
            Item item = items.get(i);
            p.setStyle(Paint.Style.FILL); p.setTypeface(Typeface.create("sans-serif-condensed", Typeface.BOLD));
            p.setTextAlign(Paint.Align.CENTER); p.setTextSize(dp(17)); p.setColor(0xFF66F5FF);
            canvas.drawText(clipGlyph(item.glyph), nx, ny - dp(5), p);
            p.setTextSize(dp(item.title.length() > 9 ? 8.2f : 9.5f));
            p.setTypeface(Typeface.create("sans-serif", Typeface.BOLD)); p.setColor(0xFFF2F7FF);
            drawLabel(canvas, item.title, nx, ny + dp(10), dp(50), p);
        }

        // Center button.
        p.setStyle(Paint.Style.FILL); p.setColor(0xFF090F19); canvas.drawCircle(cx, cy, r * .285f, p);
        p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(dp(2)); p.setColor(0xFF66F5FF); canvas.drawCircle(cx, cy, r * .285f, p);
        p.setStyle(Paint.Style.FILL); p.setTypeface(Typeface.create("sans-serif-black", Typeface.BOLD));
        p.setTextAlign(Paint.Align.CENTER); p.setTextSize(dp(27)); p.setColor(0xFF66F5FF);
        canvas.drawText(centerTitle, cx, cy - dp(1), p);
        p.setTypeface(Typeface.create("sans-serif", Typeface.BOLD)); p.setTextSize(dp(8.5f)); p.setColor(0xFFC59BFF);
        canvas.drawText(centerSubtitle, cx, cy + dp(16), p);

        p.setStyle(Paint.Style.FILL); p.setTextSize(dp(9)); p.setTypeface(Typeface.create("sans-serif", Typeface.NORMAL));
        p.setTextAlign(Paint.Align.CENTER); p.setColor(0xFF71879E);
        canvas.drawText(items.size() + ("ВЫБОР".equals(centerSubtitle) ? " категорий в круге" : " вариантов в круге"), cx, Math.min(h - dp(5), cy + r + dp(14)), p);
    }

    private Paint pWithColor(int color) {
        p.setColor(color); p.setStyle(Paint.Style.FILL); return p;
    }
    private String clipGlyph(String value) {
        if (value == null) return "•";
        return value.length() > 5 ? value.substring(0, 5) : value;
    }
    private void drawLabel(Canvas canvas, String text, float x, float y, float maxWidth, Paint paint) {
        String[] lines = text.split("\\n");
        if (lines.length == 1 && text.equals("ИНСТРУМЕНТЫ")) lines = new String[]{"ИНСТРУ", "МЕНТЫ"};
        if (lines.length == 1 && text.equals("РАЗРАБОТКА")) lines = new String[]{"РАЗРАБОТ", "КА"};
        if (lines.length == 1 && text.equals("НАСТРОЙКИ")) lines = new String[]{"НАСТРОЙ", "КИ"};
        if (lines.length == 1 && paint.measureText(text) > maxWidth) {
            int cut = Math.max(3, text.length()/2);
            while (cut > 2 && paint.measureText(text.substring(0, cut)) > maxWidth) cut--;
            lines = new String[]{text.substring(0, cut), text.substring(cut)};
        }
        for (int i=0; i<Math.min(lines.length, 2); i++) {
            String line = lines[i];
            while (line.length() > 2 && paint.measureText(line) > maxWidth) line = line.substring(0,line.length()-1);
            canvas.drawText(line, x, y + i * dp(10), paint);
        }
    }

    @Override public boolean onTouchEvent(MotionEvent event) {
        if (event.getAction() != MotionEvent.ACTION_UP) return true;
        float dx = event.getX() - getWidth()/2f;
        float dy = event.getY() - getHeight()/2f;
        float dist = (float)Math.sqrt(dx*dx + dy*dy);
        float r = Math.min(getWidth(), getHeight()) * .475f;
        if (dist < r * .30f) {
            if (listener != null) listener.onCenterTap();
            performClick();
            return true;
        }
        if (dist < r * 1.1f) {
            double deg = Math.toDegrees(Math.atan2(dy, dx));
            int index = (int)Math.round((deg + 90.0) / 45.0);
            index = (index % 8 + 8) % 8;
            selected = index;
            invalidate();
            if (listener != null) listener.onItemSelected(index);
        }
        performClick();
        return true;
    }

    @Override public boolean performClick() { super.performClick(); return true; }
}
