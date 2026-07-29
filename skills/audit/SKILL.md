---
name: audit
description: Run hi-claude audits over the project. Use when the user asks to audit, review, check, or clean the project, its CLAUDE.md, its memory, its roadmap, or its organization ("auditá", "revisá el proyecto", "limpiá esta carpeta", "check my setup", "audit"), or invokes /hi-claude:audit. Accepts an optional target argument.
argument-hint: "[claude-md | memory | organization | roadmap | inventory | all]"
---

# hi-claude Audit

Orchestrate the hi-claude auditors, consolidate one actionable report, and apply only what the user
approves.

## Steps

1. **Parse target** from `$ARGUMENTS`: `claude-md`, `memory`, `organization`, `roadmap`, `inventory`,
   or `all` (default `all`).
2. **Launch the corresponding agents in parallel** using the Agent tool (single message, multiple
   calls): `hi-claude:claude-md-auditor`, `hi-claude:memory-auditor`,
   `hi-claude:organization-auditor`, `hi-claude:roadmap-auditor`, `hi-claude:inventory-auditor`. Pass
   each one the project root path and, for the memory auditor, the project's memory directory
   (`~/.claude/projects/<slug>/memory/`).
3. **Consolidate** their structured reports into ONE message in the user's language:

Report the measurement each auditor produced, never a letter: a grade is a verdict of value on the
user's own project, and the rubrics already produce the datum.

```
## hi-claude Audit — <project>
📋 CLAUDE.md: <score/total> — <finding 1>, <finding 2>
🧠 Memory: <n checked, n with findings> — <finding 1>
🗺️ ROADMAP: <score/total> — <finding 1>
📁 Organization: <what was counted> — <finding 1>, <finding 2>
🧰 Inventory: <what was counted> — <finding 1>

Each finding: [evidence file:line] — what was observed — why it matters — proposed fix
```

4. **Respect the caps**: max 1-2 findings per category in the main report (the agents already cap; do
   not re-expand). If an agent reported a 🚨 critical (secrets in plain text), surface it FIRST
   regardless of caps.
5. **Ask what to apply** with AskUserQuestion: apply all / choose per item / nothing. NEVER apply
   without selection.
6. **Apply approved items only**, one by one (the Guardian will confirm governed writes). For
   deletions of user files, show a summary of the file's content before deleting.
7. **Close** with: "Want me to dig deeper into any category?" and, if it's been useful, remind that
   audits can run anytime.

## Edge cases

- Project with no CLAUDE.md → skip that auditor; suggest `/hi-claude:setup` instead.
- Project with no `docs/ROADMAP.md` → skip that auditor; offer to create the register.
- Project with none of the four inventory documents → skip that auditor; offer to build the inventory
  (`/hi-claude:setup` phase 5), which is what makes the project's tooling usable at all.
- Every criterion met and no findings → say so plainly with the numbers; do not invent work.
- What an auditor brings is a HYPOTHESIS. Verify each finding first-hand against the file before
  proposing it to the user — a report is evidence to check, never a decision already made.
- Do NOT trigger this skill during normal development tasks; only on explicit audit intent or an
  accepted suggestion.
