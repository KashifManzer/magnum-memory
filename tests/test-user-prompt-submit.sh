#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
HOOK="$DIR/hooks/user-prompt-submit"

state_count() { grep '^count=' "$1/.claude/memory/.mm-state" 2>/dev/null | cut -d= -f2; }

# A. dir exists, no CONTEXT.md -> counts from 1, nudge at threshold (no baseline skip)
A="$(mktemp -d)"; mkdir -p "$A/.claude/memory"
oa1="$(MAGNUM_MEMORY_NUDGE_EVERY=2 CLAUDE_PROJECT_DIR="$A" bash "$HOOK")"
assert_eq "A call1 below threshold: no output" "" "$oa1"
oa2="$(MAGNUM_MEMORY_NUDGE_EVERY=2 CLAUDE_PROJECT_DIR="$A" bash "$HOOK")"
assert_contains "A call2 at threshold: nudges" "$oa2" "additionalContext"
if printf '%s' "$oa2" | python3 -m json.tool >/dev/null 2>&1; then
  assert_eq "A nudge is valid JSON" "ok" "ok"
else
  assert_eq "A nudge is valid JSON" "ok" "invalid"
fi
ctxa="$(printf '%s' "$oa2" | python3 -c 'import json,sys;print(json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"])')"
assert_contains "A nudge mentions magnum-memory" "$ctxa" "magnum-memory"
assert_eq "A count resets after nudge" "0" "$(state_count "$A")"

# B. checkpoint (CONTEXT.md mtime advance) resets the counter
B="$(mktemp -d)"; mkdir -p "$B/.claude/memory"
MAGNUM_MEMORY_NUDGE_EVERY=5 CLAUDE_PROJECT_DIR="$B" bash "$HOOK" >/dev/null   # count=1
MAGNUM_MEMORY_NUDGE_EVERY=5 CLAUDE_PROJECT_DIR="$B" bash "$HOOK" >/dev/null   # count=2
printf '# m\n## Current State\n- x\n' > "$B/.claude/memory/CONTEXT.md"        # a checkpoint
MAGNUM_MEMORY_NUDGE_EVERY=5 CLAUDE_PROJECT_DIR="$B" bash "$HOOK" >/dev/null   # cur>last -> reset
assert_eq "B counter resets after checkpoint" "0" "$(state_count "$B")"

# C. cooldown: no nudge on the call right after a nudge
C="$(mktemp -d)"; mkdir -p "$C/.claude/memory"
MAGNUM_MEMORY_NUDGE_EVERY=2 CLAUDE_PROJECT_DIR="$C" bash "$HOOK" >/dev/null    # count=1
onud="$(MAGNUM_MEMORY_NUDGE_EVERY=2 CLAUDE_PROJECT_DIR="$C" bash "$HOOK")"     # count=2 -> nudge
assert_contains "C nudge fired" "$onud" "additionalContext"
ocool="$(MAGNUM_MEMORY_NUDGE_EVERY=2 CLAUDE_PROJECT_DIR="$C" bash "$HOOK")"    # count=1 -> cooldown
assert_eq "C cooldown: no nudge right after" "" "$ocool"

# D. disabled via env -> no output, no state written
D="$(mktemp -d)"; mkdir -p "$D/.claude/memory"
od="$(MAGNUM_MEMORY_NUDGE=off MAGNUM_MEMORY_NUDGE_EVERY=1 CLAUDE_PROJECT_DIR="$D" bash "$HOOK")"
assert_eq "D disabled: no output" "" "$od"
assert_eq "D disabled: no state file" "no" "$([ -f "$D/.claude/memory/.mm-state" ] && echo yes || echo no)"
odu="$(MAGNUM_MEMORY_NUDGE=OFF MAGNUM_MEMORY_NUDGE_EVERY=1 CLAUDE_PROJECT_DIR="$D" bash "$HOOK")"
assert_eq "D disabled (uppercase OFF): no output" "" "$odu"

# E. missing memory dir -> no-op, exit 0
E="$(mktemp -d)"
oe="$(CLAUDE_PROJECT_DIR="$E" bash "$HOOK"; echo "rc=$?")"
assert_eq "E missing memory dir: no-op exit 0" "rc=0" "$oe"

# F. corrupted .mm-state is tolerated (sanitized, no crash)
F="$(mktemp -d)"; mkdir -p "$F/.claude/memory"
printf 'count=garbage\nlast_mtime=garbage\n' > "$F/.claude/memory/.mm-state"
of="$(MAGNUM_MEMORY_NUDGE_EVERY=2 CLAUDE_PROJECT_DIR="$F" bash "$HOOK"; echo "rc=$?")"
assert_eq "F corrupt state: no crash, exit 0" "rc=0" "$of"
assert_eq "F corrupt state sanitized to count=1" "1" "$(state_count "$F")"

rm -rf "$A" "$B" "$C" "$D" "$E" "$F"
finish
