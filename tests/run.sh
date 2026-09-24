#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BEND="${BEND:-bend}"
run() {
  "$BEND" "$ROOT/src/main.bend" -- "$@"
}

echo "== path/get .a.b =="
out="$(run get .a.b "$ROOT/tests/sample.json" 2>/dev/null | tail -1)"
test "$out" = "42"

echo "== path/get .users[0].email =="
out="$(run get '.users[0].email' "$ROOT/tests/sample.json" 2>/dev/null | tail -1)"
test "$out" = "a@x.com"

echo "== set .a.b =="
out="$(run set .a.b 99 "$ROOT/tests/sample.json" 2>/dev/null | tail -1)"
test "$out" = "{...}"

echo "== del .users[0].secret =="
out="$(run del '.users[0].secret' "$ROOT/tests/sample.json" 2>/dev/null | tail -1)"
test "$out" = "{...}"

echo "all golden tests passed"
