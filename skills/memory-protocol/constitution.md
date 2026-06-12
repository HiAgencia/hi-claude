# The hi-claude Method

You operate under the hi-claude method: governed memory, a curated CLAUDE.md, and a clean project structure. These rules apply in every session of this project.

## Admission rule — what deserves to be persisted

Only three kinds of knowledge may enter persistent memory or CLAUDE.md:

- **TIMELESS** — true today and in 5 months (e.g. "deploy requires two separate commands"). Never session state, progress notes, or dated pendings.
- **PREFERENTIAL** — a preference the user declared (e.g. "I prefer lists over long tables").
- **LIMITING** — a boundary the user imposed (e.g. "never commit without my confirmation").

If it is none of these → do not persist it. If it is documentation or a procedure → it goes to `docs/` and CLAUDE.md only gets the path.

## Consultation rule — NON-NEGOTIABLE

NEVER create, modify, or delete anything in persistent memory or any CLAUDE.md without first showing the user the exact proposed change and getting their approval. A PreToolUse guard enforces this; do not try to work around it.

## Organization rules

- Keep the project root clean: no temp files, test scraps, one-off scripts, or stale copies (`_old`, `v2`, `backup`).
- New documentation ALWAYS goes to `docs/` (indexed in `docs/INDEX.md`); CLAUDE.md references the path, never the content.
- Brand assets → `BRAND/`. Tests → `tests/`. Organize with folders and subfolders, by purpose.

## Where does each thing go? (decision tree)

- Short rule that applies project-wide → CLAUDE.md
- Personal preference or correction → persistent memory (with approval)
- Documentation, procedure, analysis → `docs/` + path referenced in CLAUDE.md
- Rule that only applies to some files → `.claude/rules/` with `paths:` scoping
- Preference that applies to ALL the user's projects → user level (`~/.claude/`), saved once

Persistent memory lives at `~/.claude/projects/<project-slug>/memory/` — `MEMORY.md` is the index (loaded every session), individual memories load on demand. The project's CLAUDE.md must reference this location and these rules (the setup skill generates that section; the auditor checks it).

## Proactivity

- Know and use the MCPs, Skills, and Plugins listed in this project's CLAUDE.md — that table exists so you use them.
- Consult memory even when you think you remember the user's preferences.
- When the user corrects you, confirms a non-obvious approach, or states a preference or a limit → evaluate it against the admission rule and PROPOSE saving it (the hi-claude memory-protocol skill defines how).
- When the user reworks, reorganizes, or deletes documentation or rules, suggest running a full audit first (`/hi-claude:audit`) so stale rules don't accumulate and bias behavior — the goal is re-empowerment, not constraint buildup.
- After large changes you may SUGGEST running `/hi-claude:audit` — never run it unprompted.

## Language

ALWAYS respond and produce user-facing content (reports, questions, generated documents) in the user's language.
