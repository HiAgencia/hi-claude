---
name: audit
description: Run hi-claude audits over the project. Use when the user asks to audit, review, check, or clean the project, its CLAUDE.md, its memory, or its organization ("auditá", "revisá el proyecto", "limpiá esta carpeta", "check my setup", "audit"), or invokes /hi-claude:audit. Accepts an optional target argument.
argument-hint: "[claude-md | memory | organization | all]"
---

# hi-claude Audit

Orchestrate the three hi-claude auditors, consolidate one actionable report, and apply only what the user approves.

## Steps

1. **Parse target** from `$ARGUMENTS`: `claude-md`, `memory`, `organization`, or `all` (default `all`).
2. **Launch the corresponding agents in parallel** using the Agent tool (single message, multiple calls): `hi-claude:claude-md-auditor`, `hi-claude:memory-auditor`, `hi-claude:organization-auditor`. Pass each one the project root path and, for the memory auditor, the project's memory directory (`~/.claude/projects/<slug>/memory/`).
3. **Consolidate** their structured reports into ONE message in the user's language:

```
## hi-claude Audit — <project>
📋 CLAUDE.md: <grade> — <finding 1>, <finding 2>
🧠 Memory: <grade> — <finding 1>
📁 Organization: <grade> — <finding 1>, <finding 2>

Each finding: [evidence file:line] — why it matters — proposed fix
```

4. **Respect the caps**: max 1-2 findings per category in the main report (the agents already cap; do not re-expand). If an agent reported a 🚨 critical (secrets in plain text), surface it FIRST regardless of caps.
5. **Ask what to apply** with AskUserQuestion: apply all / choose per item / nothing. NEVER apply without selection.
6. **Apply approved items only**, one by one (the Guardian will confirm governed writes). For deletions of user files, show a summary of the file's content before deleting.
7. **Close** with: "Want me to dig deeper into any category?" and, if it's been useful, remind that audits can run anytime.

## Edge cases

- Project with no CLAUDE.md → skip that auditor; suggest `/hi-claude:setup` instead.
- All grades A and no findings → say so plainly and congratulate; do not invent work.
- Do NOT trigger this skill during normal development tasks; only on explicit audit intent or accepted suggestion.
