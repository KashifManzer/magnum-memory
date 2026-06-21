#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
HOOK="$DIR/hooks/session-start"

# Case A: populated Current State -> valid JSON containing only that section
P="$(mktemp -d)"; mkdir -p "$P/.claude/memory"
cat > "$P/.claude/memory/CONTEXT.md" <<'EOF'
# Project Context Memory

## Current State
- Goal: build the thing
- Decision: use approach X because Y

## Checkpoint Log
### 2026-01-01T00:00Z — should NOT be injected
- secret log detail

## Archive
EOF

out="$(CLAUDE_PROJECT_DIR="$P" bash "$HOOK")"
if printf '%s' "$out" | python3 -m json.tool >/dev/null 2>&1; then
  assert_eq "emits valid JSON" "ok" "ok"
else
  assert_eq "emits valid JSON" "ok" "invalid"
fi
ctx="$(printf '%s' "$out" | python3 -c 'import json,sys;print(json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"])')"
assert_contains "includes Current State content" "$ctx" "use approach X because Y"
assert_not_contains "excludes Checkpoint Log content" "$ctx" "secret log detail"

# Case B: no file -> no output, exit 0
Q="$(mktemp -d)"
out2="$(CLAUDE_PROJECT_DIR="$Q" bash "$HOOK"; echo "rc=$?")"
assert_eq "no-op when file absent" "rc=0" "$out2"

rm -rf "$P" "$Q"

# Case C: file present but no "## Current State" heading -> no-op
R="$(mktemp -d)"; mkdir -p "$R/.claude/memory"
printf '# Mem\n\n## Checkpoint Log\n### x\n- y\n\n## Archive\n' > "$R/.claude/memory/CONTEXT.md"
outR="$(CLAUDE_PROJECT_DIR="$R" bash "$HOOK"; echo "rc=$?")"
assert_eq "no-op when no Current State heading" "rc=0" "$outR"

# Case D: heading present but empty body -> no-op
E="$(mktemp -d)"; mkdir -p "$E/.claude/memory"
printf '# Mem\n\n## Current State\n\n## Checkpoint Log\n\n## Archive\n' > "$E/.claude/memory/CONTEXT.md"
outE="$(CLAUDE_PROJECT_DIR="$E" bash "$HOOK"; echo "rc=$?")"
assert_eq "no-op when Current State body empty" "rc=0" "$outE"

# Case E: special characters produce valid JSON and are preserved
F="$(mktemp -d)"; mkdir -p "$F/.claude/memory"
printf '# Mem\n\n## Current State\n- path: a\\b "q" end\n\n## Archive\n' > "$F/.claude/memory/CONTEXT.md"
outF="$(CLAUDE_PROJECT_DIR="$F" bash "$HOOK")"
if printf '%s' "$outF" | python3 -m json.tool >/dev/null 2>&1; then
  assert_eq "special chars produce valid JSON" "ok" "ok"
else
  assert_eq "special chars produce valid JSON" "ok" "invalid"
fi
ctxF="$(printf '%s' "$outF" | python3 -c 'import json,sys;print(json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"])')"
assert_contains "preserves backslash+quote content" "$ctxF" 'a\b "q" end'
rm -rf "$R" "$E" "$F"

finish
