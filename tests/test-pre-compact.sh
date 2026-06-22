#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
HOOK="$DIR/hooks/pre-compact"

P="$(mktemp -d)"; mkdir -p "$P/.claude/memory"
cat > "$P/.claude/memory/CONTEXT.md" <<'EOF'
# Project Context Memory

## Current State
- Goal: x

## Checkpoint Log

## Archive
EOF

# Marker is appended with parsed trigger, before ## Archive
printf '{"trigger":"auto"}' | CLAUDE_PROJECT_DIR="$P" bash "$HOOK"
body="$(cat "$P/.claude/memory/CONTEXT.md")"
assert_contains "marker mentions compaction (auto)" "$body" "— compaction (auto)"

# Marker line precedes the Archive heading
marker_ln="$(grep -n "compaction (auto)" "$P/.claude/memory/CONTEXT.md" | head -1 | cut -d: -f1)"
archive_ln="$(grep -n "^## Archive" "$P/.claude/memory/CONTEXT.md" | head -1 | cut -d: -f1)"
assert_eq "marker is before Archive" "yes" "$([ "$marker_ln" -lt "$archive_ln" ] && echo yes || echo no)"

# Always exits 0, even with no file
Q="$(mktemp -d)"
printf '{"trigger":"manual"}' | CLAUDE_PROJECT_DIR="$Q" bash "$HOOK"; rc=$?
assert_eq "exit 0 when file absent" "0" "$rc"

# No-Archive fallback: marker appended at end
N="$(mktemp -d)"; mkdir -p "$N/.claude/memory"
printf '# Mem\n\n## Current State\n- g\n\n## Checkpoint Log\n' > "$N/.claude/memory/CONTEXT.md"
printf '{"trigger":"auto"}' | CLAUDE_PROJECT_DIR="$N" bash "$HOOK"
lastline="$(tail -n1 "$N/.claude/memory/CONTEXT.md")"
assert_contains "marker appended at end when no Archive" "$lastline" "— compaction (auto)"

# Unknown trigger when stdin has no trigger field
U="$(mktemp -d)"; mkdir -p "$U/.claude/memory"
printf '# Mem\n\n## Checkpoint Log\n\n## Archive\n' > "$U/.claude/memory/CONTEXT.md"
printf '{}' | CLAUDE_PROJECT_DIR="$U" bash "$HOOK"
assert_contains "unknown trigger recorded" "$(cat "$U/.claude/memory/CONTEXT.md")" "compaction (unknown)"

# No Archive but a trailing section -> marker stays in the Checkpoint Log section
T="$(mktemp -d)"; mkdir -p "$T/.claude/memory"
printf '# Mem\n\n## Checkpoint Log\n### old\n- x\n\n## Notes\n- n\n' > "$T/.claude/memory/CONTEXT.md"
printf '{"trigger":"manual"}' | CLAUDE_PROJECT_DIR="$T" bash "$HOOK"
mk="$(grep -n 'compaction (manual)' "$T/.claude/memory/CONTEXT.md" | head -1 | cut -d: -f1)"
nt="$(grep -n '^## Notes' "$T/.claude/memory/CONTEXT.md" | head -1 | cut -d: -f1)"
assert_eq "marker before trailing non-Archive section" "yes" "$([ "$mk" -lt "$nt" ] && echo yes || echo no)"

rm -rf "$P" "$Q" "$N" "$U" "$T"
finish
