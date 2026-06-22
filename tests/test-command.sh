#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
C="$DIR/commands/checkpoint.md"
body="$(cat "$C" 2>/dev/null)"

assert_contains "mentions full checkpoint" "$body" "checkpoint"
assert_contains "invokes the skill or procedure" "$body" "magnum-memory"
assert_contains "ensures init" "$body" "mm-ensure-init"
assert_contains "applies complementarity rule" "$body" "compaction summary"

finish
