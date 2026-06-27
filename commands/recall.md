---
description: Search your magnum-memory history (Checkpoint Log + Archive) for past entries.
---

Search this project's magnum-memory history for: $ARGUMENTS

1. Run: `"${CLAUDE_PLUGIN_ROOT}/scripts/mm-recall" $ARGUMENTS`
2. It prints whole matching Checkpoint Log / Archive entries — every query word must
   appear (case-insensitive), most-recent (Checkpoint Log) first, then Archive.
3. Present the returned entries concisely and, if useful, summarize what they mean for
   the current task. If it prints `no matching entries`, say so and suggest broader terms.
