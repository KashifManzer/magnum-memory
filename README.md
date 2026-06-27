# magnum-memory

Persistent per-project memory for Claude Code that **survives context compaction**.

When a long conversation gets compacted, Claude's summary keeps the recent narrative
but reliably drops the durable specifics — exact file paths, config values, *why*
decisions were made, alternatives that were rejected, dead-ends already ruled out.
`magnum-memory` captures exactly those blind spots in a small per-project file so they
can be brought back after a compaction.

## How it works: A + B

- **A — the memory file** (`.claude/memory/CONTEXT.md`): the durable specifics
  compaction drops. Personal and **gitignored** (never shared with teammates).
- **B — the compaction summary**: the live narrative Claude keeps automatically.

A and B are deliberately complementary — near-zero overlap. Rejoined after a
compaction, they reconstruct the full working picture.

The file has three sections:

- **Current State** — a living, bounded snapshot (the part brought back into context).
- **Checkpoint Log** — append-only, timestamped history and rationale trail.
- **Archive** — older entries, distilled to keep the file lean.

## Install

### Quick (skill only)

```bash
npx skills add https://github.com/KashifManzer/magnum-memory --skill magnum-memory
```

Installs the `magnum-memory` skill into `.claude/skills/`. Claude maintains
`.claude/memory/CONTEXT.md`; you bring it back by reading it (or asking Claude to)
when you resume a session or right after a compaction.

### Full (plugin — adds automatic re-injection)

```bash
/plugin marketplace add KashifManzer/magnum-memory
/plugin install magnum-memory@magnum-memory-marketplace
```

Adds the `SessionStart` and `PreCompact` hooks plus the `/checkpoint` command on top of
the skill. The hooks **automatically** re-inject the Current State after every
compaction and on new/resumed sessions — no manual step. A `UserPromptSubmit` hook also
**nudges a checkpoint** if memory goes stale (default every 8 turns;
`MAGNUM_MEMORY_NUDGE_EVERY` to tune, `MAGNUM_MEMORY_NUDGE=off` to disable).

| | Quick (skill) | Full (plugin) |
|---|---|---|
| Maintains the memory file | ✅ | ✅ |
| `/checkpoint` command | — | ✅ |
| **Automatic** re-injection after compaction | manual (read the file) | ✅ via hooks |

## Usage

- Claude checkpoints durable specifics at meaningful milestones — decisions (with the
  *why* and rejected alternatives), root causes, dead-ends, key paths/configs, and
  preferences you state.
- Force a checkpoint anytime (full install) with **`/checkpoint`**.
- **Recall past work** (full plugin) with **`/recall <words>`** — searches the Checkpoint Log + Archive for entries matching all the words.
- The memory lives at `.claude/memory/CONTEXT.md` and is kept out of git via
  `.gitignore`, so it stays personal and local.

## License

[MIT](./LICENSE)
