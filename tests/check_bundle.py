from pathlib import Path
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
for file in ROOT.rglob("*.xml"):
    ET.parse(file)

catalog = (ROOT / "android/app/src/main/java/com/osaoda/dermuxru/Catalog.java").read_text(encoding="utf-8")
category_count = catalog.count('new Category(')
actions = re.findall(r'\b(?:a|d|h|ip|t|f)\("[a-z0-9]+"', catalog)
assert category_count == 8, category_count
assert len(actions) == 72, len(actions)

activity = (ROOT / "android/app/src/main/java/com/osaoda/dermuxru/RadialMenuActivity.java").read_text(encoding="utf-8")
assert "requestPinAppWidget" in activity
assert "com.termux.RUN_COMMAND" in activity
assert "Введите" in activity or "inputHint" in activity

manifest = ET.parse(ROOT / "android/app/src/main/AndroidManifest.xml").getroot()
assert manifest.find("application/receiver") is not None
assert any(x.attrib.get("{http://schemas.android.com/apk/res/android}name") == "com.termux.permission.RUN_COMMAND"
           for x in manifest.findall("uses-permission"))

bridge = (ROOT / "termux/android/dispatch.sh").read_text(encoding="utf-8")
assert "eval " not in bridge
assert "valid_domain" in bridge and "_du_confirm" in bridge
for action in ["dashboard", "selfcheck", "emailsec", "sectxt", "sitemap", "iprdap", "faviconhash", "b64encode", "b64decode", "calc", "snapshot"]:
    assert re.search(rf'^\s*{re.escape(action)}\)', bridge, re.M), action

print(f"OK: {len(list(ROOT.rglob('*.xml')))} XML files parse")
print(f"OK: {category_count} categories, {len(actions)} menu actions")
print("OK: native widget, pin request, Termux RUN_COMMAND permission")
print("OK: command allowlist and passive OSINT actions present")
