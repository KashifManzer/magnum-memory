#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
S="$DIR/skills/magnum-memory/SKILL.md"
body="$(cat "$S" 2>/dev/null)"

assert_contains "has name frontmatter" "$body" "name: magnum-memory"
assert_contains "has description frontmatter" "$body" "description:"
assert_contains "states complementarity rule" "$body" "Will the compaction summary still contain this"
assert_contains "references mm-ensure-init" "$body" "mm-ensure-init"
assert_contains "documents Current State section" "$body" "## Current State"
assert_contains "documents Checkpoint Log section" "$body" "## Checkpoint Log"
assert_contains "documents distillation" "$body" "Distillation"
assert_contains "inserts before Archive" "$body" "before"
assert_contains "documents the nudge" "$body" "nudge"

finish
