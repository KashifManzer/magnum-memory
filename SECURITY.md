# Security Policy

## Supported versions

The current minor release (0.2.x) receives security fixes.

## Reporting a vulnerability

Please report security issues **privately** by email to **kmanzer3@gmail.com** — do not
open a public issue for vulnerabilities. We aim to acknowledge reports within a few days
and will coordinate a fix and disclosure timeline with you.

## Data handling & secrets

magnum-memory stores its memory in `.claude/memory/CONTEXT.md` as **plaintext on your
local machine**.

The **primary protection is that the file never leaves your machine** — it is per-project,
**gitignored**, and never pushed or transmitted anywhere. In addition, the `magnum-memory`
skill instructs Claude to keep secret *values* out of the file (recording a safe reference,
such as an env-var name, instead of the value).

That said, there is **no automated redaction**. The file is plaintext, so if a secret does
get written into it, it remains in plaintext locally. Please do not rely on redaction —
keep secrets out of memory in the first place.
