#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA="$ROOT/benches/data"
mkdir -p "$DATA"
python3 "$ROOT/benches/gen.py" 1
python3 "$ROOT/benches/gen.py" 10

FILE="$DATA/wide_1mb.json"
JQ='.chunks[0].kids[0].kids[0].kids[0].id'

if command -v hyperfine >/dev/null 2>&1; then
  hyperfine \
    "jq -c '$JQ' '$FILE' >/dev/null" \
    "bend '$ROOT/src/main.bend' -- get '.chunks[0].kids[0].kids[0].kids[0].id' '$FILE' 2>/dev/null | tail -1 >/dev/null"
else
  echo "hyperfine not installed; using time(1)"
  /usr/bin/time -f 'jq %e' jq -c "$JQ" "$FILE" >/dev/null
  /usr/bin/time -f 'nestfold %e' bend "$ROOT/src/main.bend" -- get '.chunks[0].kids[0].kids[0].kids[0].id' "$FILE" 2>/dev/null | tail -1 >/dev/null
fi

echo "Note: nestfold wall time includes yyjson parse (C) + Bend traversal; compare honestly to jq."
