# Memory schema — single source of truth

> Auditors and skills validate against THIS file. If the native format evolves, update here only.

## Directory layout

```
~/.claude/projects/<project-slug>/memory/
├── MEMORY.md          # index — first 200 lines / 25KB load at session start
└── <type>-<slug>.md   # one fact per file
```

## File naming

`<type>-<slug>.md` — type prefix + kebab-case slug, ASCII only (no accents), short.
Examples: `feedback-no-mock-db.md`, `user-role-marketing-exec.md`, `project-deploy-two-steps.md`, `reference-linear-board.md`.

## Individual memory file format

```markdown
---
name: <kebab-case-slug, consistent with the filename>
description: <one line used to decide relevance in future sessions>
metadata:
  type: user | feedback | project | reference
---

<the fact, short and direct>

**Why:** <what incident or statement originated this>
**How to apply:** <when and how to act on it>

EXPLICIT SCOPE: <only if contextual — e.g. "only applies to N8N flows">
Related: [[other-memory-name]]
```

Notes:
- The `metadata:` block is the CURRENT native format (nested). The old flat `type:` is deprecated — auditors flag it.
- `originSessionId` may appear in auto-generated memories; leave it as is, never fabricate it.

## MEMORY.md index format

```markdown
# MEMORY.md — <project name>

- [Short title](type-slug.md) — one-line hook, max 150 chars
```

- Hard cap: 200 lines / 25KB — content beyond is silently NOT loaded. Keep it lean.
- Every memory file MUST have exactly one index line; no orphans, no broken links.
