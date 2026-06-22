---
name: magnum-memory
description: Use throughout any non-trivial or long-running task to persist the durable specifics that context compaction drops. Maintains a per-project, gitignored .claude/memory/CONTEXT.md so that, after a compaction, the file plus the compaction summary together reconstruct the full working picture.
---

# magnum-memory

Maintain a per-project memory file that survives context compaction. The compaction
summary keeps the recent narrative; this file keeps the durable specifics the summary
drops. Together they reconstruct the whole picture.

## The one rule: A = compaction's blind spots (never duplicate B)

Before writing ANYTHING, ask:

> **"Will the compaction summary still contain this on its own?"**
> - **Yes → do not write it** (live narrative, current task, high-level goal).
> - **No → write it** (durable specific or rationale compaction drops).

| Compaction (B) keeps — DO NOT duplicate | Memory file (A) captures |
|---|---|
| Recent narrative / what we're doing now | Exact file paths, config values, commands, API quirks |
| High-level goal | Why a decision was made + alternatives rejected |
| Current open task | Dead-ends ruled out (and why) |
| General arc of the conversation | Preferences / constraints stated early |

When unsure, write a terse durable fact, not a re-told story.

## The file: `.claude/memory/CONTEXT.md`

Three sections:
- **## Current State** — living; rewritten in place; bounded; the ONLY part re-injected.
- **## Checkpoint Log** — append-only, timestamped, newest entries inserted directly
  **before** the `## Archive` heading.
- **## Archive** — distilled/old log entries.

## First-run setup

Before your first write in a project, make sure the memory file exists at
`.claude/memory/CONTEXT.md`. If it is missing: create the `.claude/memory/`
directory, seed `CONTEXT.md` with the template below, and add `.claude/memory/`
to the project `.gitignore` (this memory is personal/local — never commit it).

Template (indented):

    # Project Context Memory
    <!-- Auto-maintained by magnum-memory. Personal/local - do not commit. -->
    <!-- Updated: (pending) -->

    ## Current State
    <!-- Living section: rewritten in place. Bounded. Re-read this on resume. -->

    ## Checkpoint Log
    <!-- Append-only, timestamped, newest-last (entries inserted before ## Archive). -->

    ## Archive
    <!-- Distilled/old log entries folded here. -->

If you installed magnum-memory as the full plugin, you can instead run the helper,
which does exactly this deterministically:

    "${CLAUDE_PLUGIN_ROOT}/scripts/mm-ensure-init"

## When to checkpoint (each gated by the rule above)

| Trigger | Write | Cadence |
|---|---|---|
| A decision is made | decision + why + rejected alternatives | event-driven |
| A bug is root-caused | root cause + fix | event-driven |
| A dead-end is ruled out | what was tried + why it failed | event-driven |
| A key fact is established (path/config/command/quirk) | the fact, verbatim | batched |
| A preference/constraint is stated | the preference + why | batched |
| A milestone completes | status update in Current State | batched |

Event-driven = write the moment it happens. Batched = flush at natural breakpoints.

## Write procedure (two steps)

1. **Append to Checkpoint Log:** add `### <ISO8601Z> — <title>` with a terse entry,
   inserted immediately before `## Archive`.
2. **Reconcile Current State in place:** add new load-bearing facts, update changed
   decisions, remove superseded items. Do not drop still-relevant facts. Update the
   `<!-- Updated: ... -->` timestamp.

## Distillation

When the Checkpoint Log exceeds ~40 entries or ~400 lines: confirm Current State
holds all still-relevant settled facts, then move old settled log entries into
`## Archive` (condensed). Keep recent/active entries in the log.

## Re-injection

Keep `## Current State` accurate — it is what reconstructs the picture after a
compaction. How it gets back into context depends on the install:

- **Full plugin install:** the SessionStart hook injects `## Current State`
  automatically on new/resumed sessions and after compaction. You don't do it
  manually.
- **Skill-only install (no hooks):** there is no automatic trigger. When you start
  work in a project, resume a session, or notice the context was just compacted,
  **read `.claude/memory/CONTEXT.md` yourself** and use its Current State before
  continuing.
