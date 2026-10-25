#!/usr/bin/env bash
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
while IFS= read -r -d '' file; do
  bash -n "$file"
done < <(find "$ROOT/termux" -type f -name '*.sh' -print0)
echo 'OK: Bash syntax for all bundled shell files.'
