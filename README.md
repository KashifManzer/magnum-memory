# magnum-memory

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![CI](https://github.com/KashifManzer/magnum-memory/actions/workflows/ci.yml/badge.svg)](https://github.com/KashifManzer/magnum-memory/actions/workflows/ci.yml)

**Persistent, per-project memory for Claude Code that survives context compaction — and stays out of your way.**

When a long conversation is compacted, Claude's summary keeps the recent narrative but
reliably drops the durable specifics: exact file paths, config values, *why* a decision
was made, the alternatives you rejected, the dead-ends you already ruled out.
magnum-memory captures exactly those blind spots in a small, gitignored file and brings
them back after a compaction — so you don't re-explain, re-decide, or re-discover.

It's deliberately lightweight: **Bash + Markdown, zero runtime dependencies.** No Node,
no MCP server, no database.

## The problem

Compaction is lossy in predictable ways. The summary keeps "what we're doing"; it forgets
"the precise things we figured out." Over a long session — or several — that loss
compounds into wasted time and repeated mistakes.

## How it works: A + B

- **A — the memory file** (`.claude/memory/CONTEXT.md`): the durable specifics compaction
  drops. Personal and **gitignored** (never shared with teammates).
- **B — the compaction summary**: the live narrative Claude keeps automatically.

A and B are deliberately **complementary — near-zero overlap**. Rejoined after a
compaction, they reconstruct the full working picture. magnum-memory only ever writes what
B would lose.

## Features

| | |
|---|---|
| 🧠 **Curated, not captured** | Claude writes *what matters* (decisions + rationale, dead-ends, key facts) — not a noisy transcript dump |
| ♻️ **Automatic re-injection** | A `SessionStart` hook restores the Current State after every compaction and on resume |
| ⏰ **Checkpoint nudge** | A `UserPromptSubmit` hook reminds Claude to save when memory goes stale |
| 🔎 **History recall** | `/recall <words>` searches your Checkpoint Log + Archive |
| 🪶 **Zero dependencies** | Bash + Markdown; no Node, MCP, or DB |
| 🔒 **Local & private** | Per-project, gitignored, never transmitted |
| 🛟 **Fail-safe** | Hooks never block a prompt or compaction |

## Install

### Quick (skill only)

```bash
npx skills add https://github.com/KashifManzer/magnum-memory --skill magnum-memory
```

Installs the `magnum-memory` skill into `.claude/skills/`. Claude maintains
`.claude/memory/CONTEXT.md`; you bring it back by reading it (or asking Claude to) when
you resume a session or right after a compaction.

### Full (plugin — adds automatic re-injection)

```bash
/plugin marketplace add KashifManzer/magnum-memory
/plugin install magnum-memory@magnum-memory-marketplace
```

Adds the `SessionStart`, `PreCompact`, and `UserPromptSubmit` hooks plus the
`/checkpoint` and `/recall` commands on top of the skill. The hooks **automatically**
re-inject the Current State after every compaction and on new/resumed sessions — no manual
step.

| | Quick (skill) | Full (plugin) |
|---|---|---|
| Maintains the memory file | ✅ | ✅ |
| `/checkpoint` & `/recall` commands | — | ✅ |
| **Automatic** re-injection after compaction | manual (read the file) | ✅ via hooks |
| Checkpoint nudge when stale | — | ✅ |

## How to use

### 1. Install once

Full experience (recommended):

```bash
/plugin marketplace add KashifManzer/magnum-memory
/plugin install magnum-memory@magnum-memory-marketplace
```

(Or skill-only: `npx skills add https://github.com/KashifManzer/magnum-memory --skill magnum-memory`.)

### 2. Just work — memory builds itself

Use Claude Code normally. At meaningful moments (a decision, a root cause, a dead-end, a
key path/config), Claude appends to `.claude/memory/CONTEXT.md`. You don't have to do
anything. A file in flight looks like:

```markdown
## Current State
- **Goal:** add OAuth login
- **Decisions:** use Auth.js — *why:* built-in providers; *rejected:* hand-rolled JWT
- **Load-bearing facts:** auth config at `src/auth/config.ts`; run `npm run db:migrate` after schema changes

## Checkpoint Log
### 2026-06-27T14:03Z — OAuth provider chosen
- picked Auth.js over hand-rolled JWT (refresh handled for us)
- dead-end: NextAuth v4 — incompatible with our app-router setup
```

### 3. After a compaction — it comes back automatically

With the full plugin, the `SessionStart` hook re-injects the **Current State** right after
a compaction (and on resume) as background context. Nothing to do.
*(Skill-only: ask Claude to read `.claude/memory/CONTEXT.md`, or it will when relevant.)*

### 4. Save on demand — `/checkpoint`

Force a checkpoint anytime (e.g. before ending a session):

```text
/checkpoint
```

Claude writes anything durable since the last save and reports a one-line summary.

### 5. Look up past work — `/recall`

```text
/recall redis timeout
```

Returns whole matching entries from the Checkpoint Log + Archive, newest first. Matching is
**per-word (AND), case-insensitive — not a phrase**: every word must appear in the entry.
Example output:

```text
### 2026-06-20T10:00Z — redis timeout fix
- raised the redis connection timeout to 5s
```

Tip: fewer words = broader results; more words = narrower. No matches prints
`no matching entries` — try broader terms.

### 6. Tune it (optional)

```bash
export MAGNUM_MEMORY_NUDGE_EVERY=12   # nudge to checkpoint less often (default 8 turns)
export MAGNUM_MEMORY_RECALL_LIMIT=20  # return more /recall results (default 10)
export MAGNUM_MEMORY_NUDGE=off        # turn the checkpoint nudge off entirely
```

## The memory file

`.claude/memory/CONTEXT.md` has three sections:

- **Current State** — a living, bounded snapshot. **This is the only part re-injected.**
- **Checkpoint Log** — append-only, timestamped history and rationale trail.
- **Archive** — older entries, distilled to keep the file lean.

It is added to your project's `.gitignore` automatically, so it stays personal and local.

## Configuration

All optional, via environment variables:

| Variable | Default | Effect |
|---|---|---|
| `MAGNUM_MEMORY_NUDGE` | (on) | Set to `off`/`0`/`false` (any case) to disable; any other value or unset leaves the checkpoint nudge enabled |
| `MAGNUM_MEMORY_NUDGE_EVERY` | `8` | Turns since last checkpoint before nudging |
| `MAGNUM_MEMORY_RECALL_LIMIT` | `10` | Max entries `/recall` returns |

## Architecture

- **Skill** (`skills/magnum-memory/SKILL.md`) — what to capture (only compaction's blind
  spots) and how to write/distill it.
- **Hooks** — `session-start` (re-inject Current State), `pre-compact` (record a
  compaction-boundary marker), `user-prompt-submit` (stale-memory nudge); wired in
  `hooks/hooks.json`.
- **Scripts** — `mm-ensure-init` (create the file + gitignore entry), `mm-recall` (history
  search).
- **Commands** — `/checkpoint`, `/recall`.

## How it compares

- **vs. manual notes:** magnum-memory captures automatically and re-injects after
  compaction; you don't have to remember to write or re-read anything.
- **vs. heavy "capture-everything" tools** (transcript archives, search indexes, MCP
  servers): those are more powerful for cross-project search, but require a runtime and
  store a lot of (often redundant) content. magnum-memory is intentionally minimal and
  *curated* — it stores only what compaction loses, with zero dependencies. Different
  trade-off, honestly: if you want a full searchable archive across all projects, a
  heavier tool fits better.

## FAQ

**Does it slow Claude down?** No. The hooks are tiny Bash scripts that always exit 0 and
never block a prompt or compaction.

**Where is my data?** In `.claude/memory/CONTEXT.md` in your project, gitignored. It is
local-only and never transmitted anywhere.

**Does it store secrets?** The file is plaintext and magnum-memory does **not** redact
secrets yet — avoid having Claude write credentials into memory. See
[SECURITY.md](./SECURITY.md).

**Skill-only vs. full plugin?** Skill-only maintains the file and you recall/re-read
manually. The full plugin adds the hooks (automatic re-injection + nudge) and the
`/checkpoint` / `/recall` commands.

## Contributing

Contributions welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md). Changelog: [CHANGELOG.md](./CHANGELOG.md).

## License

[MIT](./LICENSE)
