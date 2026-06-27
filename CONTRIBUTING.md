# Contributing to magnum-memory

Thanks for your interest! magnum-memory is a small, dependency-free Claude Code plugin
(Bash + Markdown). Contributions of all kinds are welcome.

## Project layout

- `skills/magnum-memory/SKILL.md` — the skill (the model-facing instructions)
- `hooks/` — `session-start`, `pre-compact`, `user-prompt-submit` (extensionless bash),
  wired in `hooks/hooks.json` via the `run-hook.cmd` cross-platform wrapper
- `commands/` — slash commands (`/checkpoint`, `/recall`)
- `scripts/` — `mm-ensure-init` (setup), `mm-recall` (history search)
- `tests/` — bash tests + the shared `tests/lib.sh` assertions
- `.claude-plugin/` — `plugin.json` + `marketplace.json`
- `docs/` — specs and plans

## Dev setup

No build step. You need `bash`, `python3` (tests validate JSON), and `shellcheck`
(linting). Clone the repo and you're ready.

## Running the tests

```bash
for t in tests/test-*.sh; do echo "== $t =="; bash "$t" || exit 1; done
```

Each file ends with `N run, 0 failed`. Lint the bash:

```bash
shellcheck --severity=warning hooks/session-start hooks/pre-compact \
  hooks/user-prompt-submit scripts/mm-ensure-init scripts/mm-recall tests/*.sh
```

(`hooks/run-hook.cmd` is a bat/bash polyglot and is intentionally not shellchecked.)

## Conventions

- **Hooks are fail-safe:** always `exit 0`, never block a prompt or compaction; use
  `set -uo pipefail` (not `set -e`).
- **Hook scripts are extensionless** (Windows auto-detection); wire them in
  `hooks/hooks.json` through `run-hook.cmd`.
- **TDD:** add a `tests/test-*.sh` using `tests/lib.sh` (`assert_eq`, `assert_contains`,
  `assert_not_contains`, `finish`). Write the failing test first.
- **Context injection** uses the
  `{"hookSpecificOutput":{"hookEventName":"…","additionalContext":"…"}}` shape.
- **Per-project memory** lives at `.claude/memory/` and is gitignored — never commit it.

## Commits & PRs

- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`,
  `docs:`, `chore:`, `test:`.
- Before opening a PR: tests green and shellcheck clean.
- Be respectful — see [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).
