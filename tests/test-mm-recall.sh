#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
SCRIPT="$DIR/scripts/mm-recall"

P="$(mktemp -d)"; mkdir -p "$P/.claude/memory"
cat > "$P/.claude/memory/CONTEXT.md" <<'EOF'
# Project Context Memory

## Current State
- using redis in current state CSONLY

## Checkpoint Log
### 2026-06-20T10:00Z — redis timeout fix
- raised the redis connection timeout to 5s

### 2026-06-21T11:00Z — auth decision
- chose JWT because stateless

## Archive
### 2026-01-01T00:00Z — old redis note
- initial redis setup
EOF

run() { CLAUDE_PROJECT_DIR="$P" bash "$SCRIPT" "$@"; }

# 1. AND match: "redis timeout" returns the timeout entry, excludes the auth entry
o="$(run redis timeout)"
assert_contains "AND match returns timeout entry" "$o" "raised the redis connection timeout"
assert_not_contains "AND match excludes non-matching entry" "$o" "chose JWT"

# 2. case-insensitive
o="$(run REDIS TIMEOUT)"
assert_contains "case-insensitive match" "$o" "redis timeout fix"

# 3. whole-entry output (header + body)
o="$(run timeout)"
assert_contains "whole entry: header" "$o" "redis timeout fix"
assert_contains "whole entry: body bullet" "$o" "raised the redis connection timeout"

# 4. no match
o="$(run nonexistentxyz)"
assert_eq "no match message" "no matching entries" "$o"

# 5. Current State never returned
o="$(run redis)"
assert_not_contains "current state excluded" "$o" "CSONLY"

# 6. Archive is searched
o="$(run initial)"
assert_contains "archive entry searched" "$o" "initial redis setup"

# 7. cap honored
o="$(MAGNUM_MEMORY_RECALL_LIMIT=1 run redis)"
hc="$(printf '%s\n' "$o" | grep -c '^### ')"
assert_eq "cap limits to 1 entry" "1" "$hc"
assert_contains "cap notes omitted matches" "$o" "omitted"

# 8. missing CONTEXT.md -> message + exit 0
Q="$(mktemp -d)"
o="$(CLAUDE_PROJECT_DIR="$Q" bash "$SCRIPT" redis; echo "rc=$?")"
assert_eq "missing file: message + exit 0" "no matching entries
rc=0" "$o"

# 9. empty query (zero args) -> message + exit 0
o="$(CLAUDE_PROJECT_DIR="$P" bash "$SCRIPT"; echo "rc=$?")"
assert_eq "empty query: message + exit 0" "no matching entries
rc=0" "$o"

rm -rf "$P" "$Q"
finish
