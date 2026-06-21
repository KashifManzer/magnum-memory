#!/usr/bin/env bash
# Minimal test helpers for magnum-memory.
set -uo pipefail
TESTS_RUN=0
TESTS_FAILED=0

assert_eq() { # desc expected actual
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ "$2" = "$3" ]; then
    echo "ok - $1"
  else
    echo "FAIL - $1"; echo "  expected: [$2]"; echo "  actual:   [$3]"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_contains() { # desc haystack needle
  TESTS_RUN=$((TESTS_RUN + 1))
  if printf '%s' "$2" | grep -qF -- "$3"; then
    echo "ok - $1"
  else
    echo "FAIL - $1"; echo "  missing substring: [$3]"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_not_contains() { # desc haystack needle
  TESTS_RUN=$((TESTS_RUN + 1))
  if printf '%s' "$2" | grep -qF -- "$3"; then
    echo "FAIL - $1"; echo "  unexpected substring: [$3]"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    echo "ok - $1"
  fi
}

finish() {
  echo "---"
  echo "$TESTS_RUN run, $TESTS_FAILED failed"
  [ "$TESTS_FAILED" -eq 0 ]
}
