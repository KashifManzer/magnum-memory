#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
body="$(cat "$DIR/commands/recall.md" 2>/dev/null)"

assert_contains "command mentions recall" "$body" "recall"
assert_contains "command runs mm-recall" "$body" "mm-recall"
assert_contains "command passes arguments" "$body" "ARGUMENTS"

finish
