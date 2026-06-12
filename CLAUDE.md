<!-- hi-claude dogfooding: this repo follows its own method. -->
# hi-claude (plugin source)

Claude Code plugin packaging the hi-claude method: governed memory, curated CLAUDE.md, clean structure, audits. This repo is BOTH the plugin and its marketplace.

## How to work here — the hi-claude method

- Only TIMELESS, PREFERENTIAL, or LIMITING knowledge enters this file or memory.
- ALWAYS consult before saving/modifying/deleting in memory or this file.
- Documentation does NOT live here: `docs/` + `docs/INDEX.md`; this file only references paths.
- Clean root; everything in its folder.

## Project structure

```
.claude-plugin/   manifests (plugin.json + marketplace.json)
hooks/            hooks.json + run-hook.cmd (polyglot) + session-start + guardian
skills/           memory-protocol (constitution + references), setup (+ templates es/en), audit
agents/           3 read-only auditors
BRAND/            Hi Agencia logo (white = dark mode, dark = light mode, used by README)
docs/             INDEX.md (public docs index)
tests/fixtures/   stdin fixtures for hook testing
```

## Key rules

- Design docs, plans, and eval methodology live in the PRIVATE repo `HiAgencia/hi-claude-internal` (full dev history archived there). Never commit them here.
- All plugin content in English; user-facing output adapts to the user's language at runtime; templates exist in `es/` and `en/`.
- Memory format reference: `skills/memory-protocol/references/memory-schema.md` is the single source of truth — native format changes are updated THERE only.
- Hook scripts are extensionless (Windows auto-detection workaround); test them with the fixtures in `tests/fixtures/` before committing changes.
- Known Guardian limitation: it intercepts Write/Edit only — file writes via Bash (`echo >> CLAUDE.md`) or NotebookEdit are covered behaviorally by the Constitution, not by the hook.
- License: MIT, copyright Hi Agencia.
