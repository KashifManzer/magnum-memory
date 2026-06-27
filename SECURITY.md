# Security Policy

## Supported versions

The current minor release (0.2.x) receives security fixes.

## Reporting a vulnerability

Please report security issues **privately** by email to **kmanzer3@gmail.com** — do not
open a public issue for vulnerabilities. We aim to acknowledge reports within a few days
and will coordinate a fix and disclosure timeline with you.

## Data handling & redaction caveat

magnum-memory stores its memory in `.claude/memory/CONTEXT.md` as **plaintext on your
local machine**. The file is gitignored and is never transmitted anywhere.

However, magnum-memory does **not** currently redact secrets. If Claude writes a
credential, API key, or other sensitive value into the memory file, it will be stored in
plaintext. Avoid having secrets captured into memory. Automatic redaction is on the
roadmap.
