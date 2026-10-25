#!/data/data/com.termux/files/usr/bin/bash
set -eu
base="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
count=0
while IFS= read -r -d '' f; do bash -n "$f"; printf '[OK] %s\n' "${f#"$base/"}"; count=$((count+1)); done < <(find "$base" -type f -name '*.sh' -print0)
echo "Syntax check complete: $count shell scripts passed; nothing was executed."
