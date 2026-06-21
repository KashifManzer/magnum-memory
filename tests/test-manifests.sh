#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

# plugin.json is valid JSON
if python3 -m json.tool "$DIR/.claude-plugin/plugin.json" >/dev/null 2>&1; then
  assert_eq "plugin.json is valid JSON" "ok" "ok"
else
  assert_eq "plugin.json is valid JSON" "ok" "invalid"
fi

name="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["name"])' "$DIR/.claude-plugin/plugin.json" 2>/dev/null)"
assert_eq "plugin name is magnum-memory" "magnum-memory" "$name"

lic="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["license"])' "$DIR/.claude-plugin/plugin.json" 2>/dev/null)"
assert_eq "license is MIT" "MIT" "$lic"

# marketplace.json valid + lists the plugin
if python3 -m json.tool "$DIR/.claude-plugin/marketplace.json" >/dev/null 2>&1; then
  assert_eq "marketplace.json is valid JSON" "ok" "ok"
else
  assert_eq "marketplace.json is valid JSON" "ok" "invalid"
fi
mp="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["plugins"][0]["name"])' "$DIR/.claude-plugin/marketplace.json" 2>/dev/null)"
assert_eq "marketplace lists magnum-memory" "magnum-memory" "$mp"

# LICENSE mentions MIT
assert_contains "LICENSE is MIT" "$(cat "$DIR/LICENSE" 2>/dev/null)" "MIT License"

finish
