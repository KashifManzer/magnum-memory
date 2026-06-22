#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

# hooks.json is valid JSON with the two events + matchers
if python3 -m json.tool "$DIR/hooks/hooks.json" >/dev/null 2>&1; then
  assert_eq "hooks.json valid JSON" "ok" "ok"
else
  assert_eq "hooks.json valid JSON" "ok" "invalid"
fi
hj="$(cat "$DIR/hooks/hooks.json")"
assert_contains "wires SessionStart" "$hj" "SessionStart"
assert_contains "SessionStart matcher includes compact" "$hj" "startup|resume|clear|compact"
assert_contains "wires PreCompact" "$hj" "PreCompact"
assert_contains "uses run-hook.cmd wrapper" "$hj" "run-hook.cmd"
assert_contains "references session-start script" "$hj" "session-start"
assert_contains "references pre-compact script" "$hj" "pre-compact"

# run-hook.cmd dispatches to a named script on Unix
TMP="$(mktemp -d)"; mkdir -p "$TMP/hooks"
cp "$DIR/hooks/run-hook.cmd" "$TMP/hooks/"
printf '#!/usr/bin/env bash\necho DISPATCHED\n' > "$TMP/hooks/demo"; chmod +x "$TMP/hooks/demo"
out="$(bash "$TMP/hooks/run-hook.cmd" demo)"
assert_eq "run-hook.cmd dispatches" "DISPATCHED" "$out"

rm -rf "$TMP"
finish
