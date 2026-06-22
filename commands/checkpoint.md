---
description: Force a full magnum-memory checkpoint of the current conversation now.
---

Run a full **magnum-memory** checkpoint right now.

1. Ensure setup: run `"${CLAUDE_PLUGIN_ROOT}/scripts/mm-ensure-init"`.
2. Follow the `magnum-memory` skill's write procedure for everything worth keeping
   since the last checkpoint.
3. Apply the rule to every item: only write what the **compaction summary** would
   drop (durable specifics, decision rationale, dead-ends, paths, configs,
   preferences) — never duplicate the live narrative.
4. Append timestamped entries to the Checkpoint Log (before `## Archive`) and
   reconcile the Current State section in place.

Report a one-line summary of what you saved.
