<div align="center">

# 🧠 magnum-memory

### Persistent memory for Claude Code that survives context compaction

*Stop re-explaining your project after every compaction. magnum-memory quietly remembers the
durable specifics Claude forgets — and brings them right back.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![CI](https://github.com/KashifManzer/magnum-memory/actions/workflows/ci.yml/badge.svg)](https://github.com/KashifManzer/magnum-memory/actions/workflows/ci.yml)
![Dependencies: zero](https://img.shields.io/badge/dependencies-zero-brightgreen)
![Built for Claude Code](https://img.shields.io/badge/built%20for-Claude%20Code-8B5CF6)

</div>

---

## 😖 The problem

When Claude Code compacts a long conversation, the summary keeps *what you're doing* — but
reliably drops *the precise things you figured out*: exact file paths, config values, **why**
a decision was made, the alternatives you rejected, the dead-ends you already ruled out.

So you re-explain. You re-decide. You re-discover. Over a long session — or several — that
loss compounds into wasted time and repeated mistakes.

## ✨ Why magnum-memory

- **🎯 It remembers the right things.** Claude curates the durable specifics into a tiny file — not a noisy transcript dump.
- **♻️ It comes back automatically.** After every compaction, the saved context is re-injected — no manual step.
- **🪶 It's featherweight.** Pure Bash + Markdown. No Node, no MCP server, no database — nothing to install or maintain.
- **🔒 It's private by default.** One per-project, **gitignored** file that never leaves your machine.

## ⚡ Quick start

```bash
/plugin marketplace add KashifManzer/magnum-memory
/plugin install magnum-memory@magnum-memory-marketplace
```

That's it — Claude now keeps a memory and restores it after compaction. Prefer just the
skill? Install it in one line:

```bash
npx skills add https://github.com/KashifManzer/magnum-memory --skill magnum-memory
```

## 🧩 How it works: A + B

> **The core idea: store only what compaction forgets.**

- **A — the memory file** (`.claude/memory/CONTEXT.md`): the durable specifics compaction drops. Personal and **gitignored** (never shared with teammates).
- **B — the compaction summary**: the live narrative Claude keeps automatically.

A and B are deliberately **complementary — near-zero overlap**. Rejoined after a compaction,
they reconstruct the full working picture. magnum-memory only ever writes what B would lose,
so the context it brings back stays small and high-signal.

## 🚀 Features

| | |
|---|---|
| 🧠 **Curated, not captured** | Claude writes *what matters* (decisions + rationale, dead-ends, key facts) — not a transcript dump |
| ♻️ **Automatic re-injection** | A `SessionStart` hook restores the Current State after every compaction and on resume |
| ⏰ **Checkpoint nudge** | A `UserPromptSubmit` hook reminds Claude to save when memory goes stale |
| 🔎 **History recall** | `/recall <words>` searches your Checkpoint Log + Archive |
| 🪶 **Zero dependencies** | Bash + Markdown; no Node, MCP, or DB |
| 🔒 **Local & private** | Per-project, gitignored, never transmitted |
| 🛟 **Fail-safe** | Hooks never block a prompt or compaction |

## 📦 Install

### Quick (skill only)

```bash
npx skills add https://github.com/KashifManzer/magnum-memory --skill magnum-memory
```

Installs the `magnum-memory` skill into `.claude/skills/`. Claude maintains
`.claude/memory/CONTEXT.md`; you bring it back by reading it (or asking Claude to) when you
resume a session or right after a compaction.

### Full (plugin — adds automatic re-injection)

```bash
/plugin marketplace add KashifManzer/magnum-memory
/plugin install magnum-memory@magnum-memory-marketplace
```

Adds the `SessionStart`, `PreCompact`, and `UserPromptSubmit` hooks plus the `/checkpoint`
and `/recall` commands on top of the skill. The hooks **automatically** re-inject the Current
State after every compaction and on new/resumed sessions — no manual step.

| | Quick (skill) | Full (plugin) |
|---|---|---|
| Maintains the memory file | ✅ | ✅ |
| `/checkpoint` & `/recall` commands | — | ✅ |
| **Automatic** re-injection after compaction | manual (read the file) | ✅ via hooks |
| Checkpoint nudge when stale | — | ✅ |

## 📖 How to use

### 1. Install once

Full experience (recommended):

```bash
/plugin marketplace add KashifManzer/magnum-memory
/plugin install magnum-memory@magnum-memory-marketplace
```

(Or skill-only: `npx skills add https://github.com/KashifManzer/magnum-memory --skill magnum-memory`.)

### 2. Just work — memory builds itself

Use Claude Code normally. At meaningful moments (a decision, a root cause, a dead-end, a key
path/config), Claude appends to `.claude/memory/CONTEXT.md`. You don't have to do anything.
A file in flight looks like:

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

With the full plugin, the `SessionStart` hook re-injects the **Current State** right after a
compaction (and on resume) as background context. Nothing to do.
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

## 🗂️ The memory file

`.claude/memory/CONTEXT.md` has three sections:

- **Current State** — a living, bounded snapshot. **This is the only part re-injected.**
- **Checkpoint Log** — append-only, timestamped history and rationale trail.
- **Archive** — older entries, distilled to keep the file lean.

It's added to your project's `.gitignore` automatically, so it stays personal and local.

## ⚙️ Configuration

All optional, via environment variables:

| Variable | Default | Effect |
|---|---|---|
| `MAGNUM_MEMORY_NUDGE` | (on) | Set to `off`/`0`/`false` (any case) to disable; any other value or unset leaves the checkpoint nudge enabled |
| `MAGNUM_MEMORY_NUDGE_EVERY` | `8` | Turns since last checkpoint before nudging |
| `MAGNUM_MEMORY_RECALL_LIMIT` | `10` | Max entries `/recall` returns |

## 🏗️ Architecture

- **Skill** (`skills/magnum-memory/SKILL.md`) — what to capture (only compaction's blind spots) and how to write/distill it.
- **Hooks** — `session-start` (re-inject Current State), `pre-compact` (record a compaction-boundary marker), `user-prompt-submit` (stale-memory nudge); wired in `hooks/hooks.json`.
- **Scripts** — `mm-ensure-init` (create the file + gitignore entry), `mm-recall` (history search).
- **Commands** — `/checkpoint`, `/recall`.

## 🔍 How it compares

Claude Code has a healthy ecosystem of memory tools — several of them more mature and
feature-rich than this one. magnum-memory isn't trying to replace them; it's a small, focused
take for people who want a lightweight, per-project memory with no runtime to manage. The
snapshot below is meant to be neutral and factual so you can choose what fits your needs —
each of these projects is excellent at what it sets out to do.

| Tool | Approach | Storage | Search / recall | Runtime | License |
|---|---|---|---|---|---|
| **magnum-memory** | Curated "only what compaction drops"; re-injects Current State | Per-project, gitignored `CONTEXT.md` (Markdown) | `/recall` — grep over Log + Archive (per-word AND) | Bash + Markdown, no runtime deps | MIT |
| [c0ntextKeeper](https://github.com/Capnjbrown/c0ntextKeeper) | Automatic transcript capture; pattern-based extraction; secret redaction | Global JSON archives | MCP tools + CLI (keyword + scoring) | TypeScript / Node + MCP server | MIT |
| [claude-mem](https://github.com/thedotmack/claude-mem) | Captures sessions, AI-compresses, re-injects | SQLite (FTS5) + vector DB | Vector + keyword (MCP + web UI) | Node / Bun + local worker | Apache-2.0 |
| [memory-bank-skill](https://github.com/chuck-ma/memory-bank-skill) | Maintains a structured Markdown "memory bank"; auto-injects | Hierarchical Markdown (`MEMORY.md` + `details/`) | Whole-bank injection (capped ~12k chars) | TypeScript / bun | see repo |
| [CLAUDE.md](https://code.claude.com/docs/en/memory) (native) | Hand-written durable project instructions | `CLAUDE.md` (Markdown) | — (always loaded) | built-in | n/a |

### What magnum-memory does especially well

In the spirit of *different tools, different strengths*, a few things we're proud of:

- **Truly zero-dependency** — no Node, database, vector store, or background daemon; just Bash and a Markdown file. It runs anywhere `bash` does and adds nothing to maintain.
- **A sharp guiding principle — store only what compaction forgets.** Rather than capturing everything and searching it later, magnum-memory deliberately saves the *complement* of the compaction summary, so re-injected context stays small and high-signal.
- **Private and portable by default** — memory is one human-readable, per-project, gitignored file you can open, diff, or delete; nothing leaves your machine.
- **Small but carefully built** — 100+ test assertions plus CI (shellcheck, JSON validation, and the full suite) behind a few hundred lines of Bash.

None of this makes it "better" — just a clear, honest niche. If you want a full, searchable
archive of your history across sessions and projects, the capture-everything tools above are
a great choice. If you'd rather have something tiny and private that simply brings back what a
compaction dropped, magnum-memory may be a good fit — and many people happily use more than one.

> *Comparison researched 2026-06-27 from each project's public repository. These tools evolve
> quickly, so please verify the latest details upstream — corrections are very welcome via an
> issue or PR.*

## ❓ FAQ

**Does it slow Claude down?** No. The hooks are tiny Bash scripts that always exit 0 and never
block a prompt or compaction.

**Where is my data?** In `.claude/memory/CONTEXT.md` in your project, gitignored. It's
local-only and never transmitted anywhere.

**Does it store secrets?** The memory file never leaves your machine — it's gitignored and
never pushed or transmitted. The skill also instructs Claude to keep secret *values* out of it
(recording a safe reference like an env-var name instead). There is **no automated redaction**,
though, and the file is plaintext — so don't rely on it; keep secrets out of memory. See
[SECURITY.md](./SECURITY.md).

**Skill-only vs. full plugin?** Skill-only maintains the file and you recall/re-read manually.
The full plugin adds the hooks (automatic re-injection + nudge) and the `/checkpoint` /
`/recall` commands.

## 🤝 Contributing

Contributions welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md). Changelog: [CHANGELOG.md](./CHANGELOG.md).

## 📄 License

[MIT](./LICENSE) © magnum-memory contributors

<div align="center">
<sub>Built for the Claude Code community.</sub>
</div>
