# Changelog

All notable changes to magnum-memory are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- The `magnum-memory` skill now instructs Claude to keep secret *values* out of the memory
  file (recording a safe reference, e.g. an env-var name, instead). Guidance only — there
  is no automated redaction; the file remains local and gitignored.

## [0.2.0] - 2026-06-26

### Added
- **Checkpoint nudge**: a `UserPromptSubmit` hook that reminds Claude to checkpoint when
  the memory has gone stale (turn-count based, default every 8 turns). Tunable via
  `MAGNUM_MEMORY_NUDGE_EVERY`; disable with `MAGNUM_MEMORY_NUDGE=off`.
- **History recall**: the `/recall <words>` command and `scripts/mm-recall` — searches the
  Checkpoint Log + Archive for entries matching all query words (case-insensitive, per
  word). Result cap tunable via `MAGNUM_MEMORY_RECALL_LIMIT` (default 10).

## [0.1.0] - 2026-06-21

### Added
- Initial release: the `magnum-memory` skill (per-project `.claude/memory/CONTEXT.md`).
- `SessionStart` and `PreCompact` hooks (re-inject Current State; record compaction
  boundary).
- `/checkpoint` command and the `mm-ensure-init` setup helper.
- Dual install: skill-only (`npx skills add`) and full plugin (hooks + command).

[Unreleased]: https://github.com/KashifManzer/magnum-memory/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/KashifManzer/magnum-memory/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/KashifManzer/magnum-memory/releases/tag/v0.1.0
