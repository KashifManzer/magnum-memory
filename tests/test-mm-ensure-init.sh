#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
SCRIPT="$DIR/scripts/mm-ensure-init"

# Case A: git repo — creates file, template sections, and gitignore entry
A="$(mktemp -d)"; git -C "$A" init -q
out="$(bash "$SCRIPT" "$A")"
assert_eq "prints CONTEXT.md path" "$A/.claude/memory/CONTEXT.md" "$out"
assert_contains "CONTEXT has Current State" "$(cat "$A/.claude/memory/CONTEXT.md")" "## Current State"
assert_contains "CONTEXT has Checkpoint Log" "$(cat "$A/.claude/memory/CONTEXT.md")" "## Checkpoint Log"
assert_contains "CONTEXT has Archive" "$(cat "$A/.claude/memory/CONTEXT.md")" "## Archive"
assert_contains "gitignore has memory dir" "$(cat "$A/.gitignore")" ".claude/memory/"

# Idempotency: run again — no duplicate gitignore line, file preserved
echo "SENTINEL" >> "$A/.claude/memory/CONTEXT.md"
bash "$SCRIPT" "$A" >/dev/null
count="$(grep -cxF ".claude/memory/" "$A/.gitignore")"
assert_eq "no duplicate gitignore entry" "1" "$count"
assert_contains "existing CONTEXT preserved" "$(cat "$A/.claude/memory/CONTEXT.md")" "SENTINEL"

# Case B: non-git dir — still creates file, but no .gitignore written
B="$(mktemp -d)"
bash "$SCRIPT" "$B" >/dev/null
assert_eq "CONTEXT created without git" "yes" "$([ -f "$B/.claude/memory/CONTEXT.md" ] && echo yes || echo no)"
assert_eq "no gitignore in non-git dir" "no" "$([ -f "$B/.gitignore" ] && echo yes || echo no)"

rm -rf "$A" "$B"

# Case C: relative path argument -> absolute path on stdout
C_PARENT="$(mktemp -d)"; mkdir -p "$C_PARENT/proj"
outC="$(cd "$C_PARENT" && bash "$SCRIPT" "proj")"
case "$outC" in /*) absC=yes ;; *) absC=no ;; esac
assert_eq "relative arg yields absolute path" "yes" "$absC"
assert_contains "absolute path ends correctly" "$outC" "/proj/.claude/memory/CONTEXT.md"
rm -rf "$C_PARENT"

finish
