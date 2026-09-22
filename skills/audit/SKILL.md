---
name: audit
description: |
  Run hi-claude audits over the project. Use when the user asks to audit, review, check, or clean the project, its CLAUDE.md, its memory, its roadmap, its organization, or whether its documentation is still true ("auditá", "revisá el proyecto", "limpiá esta carpeta", "¿esto sigue sirviendo?", "está lleno de cosas viejas", "check my setup", "audit", "is any of this still true"), and right after the hi-claude plugin is updated or when they ask what a new version asks of their project ("actualicé el plugin", "qué trae la nueva versión", "¿tengo que cambiar algo?", "I updated the plugin", "do I need to change anything"). Also on /hi-claude:audit. Accepts an optional target argument.
argument-hint: "[claude-md | memory | organization | roadmap | inventory | currency | adoption | all]"
---

# hi-claude Audit

Orchestrate the hi-claude auditors, consolidate one actionable report, and apply only what the user
approves.

## Steps

1. **Parse target** from `$ARGUMENTS`: `claude-md`, `memory`, `organization`, `roadmap`, `inventory`,
   `currency`, `adoption`, or `all` (default `all`). Right after a plugin update the target is
   `adoption`, which dispatches no agent — see its section below.
2. **Launch the corresponding agents in parallel** using the Agent tool (single message, multiple
   calls): `hi-claude:claude-md-auditor`, `hi-claude:memory-auditor`,
   `hi-claude:organization-auditor`, `hi-claude:roadmap-auditor`, `hi-claude:inventory-auditor`,
   `hi-claude:currency-auditor`. Pass each one the project root path and, for the memory auditor, the
   project's memory directory (`~/.claude/projects/<slug>/memory/`).
3. **Consolidate** their structured reports into ONE message in the user's language:

Report the measurement each auditor produced, never a letter: a grade is a verdict of value on the
user's own project, and the rubrics already produce the datum. Plain text labels, no emojis.

```
## hi-claude Audit — <project>
CLAUDE.md: <score/total> — <finding 1>, <finding 2>
Memory: <n checked, n with findings> — <finding 1>
ROADMAP: <score/total> — <finding 1>
Organization: <what was counted> — <finding 1>, <finding 2>
Inventory: <what was counted> — <finding 1>
Currency: <n lines that expired of n> — <finding 1>, <finding 2>
Adoption: <what applies here, each with its number> — or "nothing applies"

Each finding: [evidence file:line] — what was observed — why it matters — proposed fix
```

4. **Respect the caps**: max 1-2 findings per category in the main report (the agents already cap; do
   not re-expand). If an agent reported a CRITICAL (secrets in plain text), surface it FIRST
   regardless of caps.
5. **Ask what to apply** with AskUserQuestion: apply all / choose per item / nothing. NEVER apply
   without selection.
6. **Apply approved items only**, one by one (the Guardian will confirm governed writes). For
   deletions of user files, show a summary of the file's content before deleting.
7. **Close** with: "Want me to dig deeper into any category?"

## Adoption — what the plugin offers NOW that this project is not using

Not a changelog and not a health check: a project can be perfectly healthy and still be missing every
capability below, and nothing else knows what the plugin gained. Measure THIS project by EFFECT — count
the characters, open the file, run the command; never assume from a version number — and report only
what applies, each with ITS number. What is already adopted gets one line. PROPOSE, never apply. If
nothing applies, say so in one line and stop.

> **Rewritten at every release, never stacked.** An item leaves when it stops being adoptable. Only
> what asks something OF THE PROJECT enters: a change that just works asks nothing and does not belong.

**Version that carries this panorama: 5.0.1**

- **THE PRINCIPLES LIVE IN THE USER'S GLOBAL CLAUDE.md.** What weighs on every session belongs in the
  file the runtime loads whole, in the user's language; what is situational arrives through the hooks.
  *Measure:* does `~/.claude/CLAUDE.md` carry the `hi-claude:principios` markers? *Do:* propose the
  block from `skills/setup/templates/<lang>/PRINCIPLES.template.md`, as the exact change, through
  `hi-claude:memory-protocol`. While it is absent the session start keeps injecting the Constitution,
  so nothing is lost by declining — it is a second copy in a second vocabulary that goes away.
- **A PROJECT CLAUDE.md WITHOUT THE METHOD'S BOILERPLATE.** With the principles in the global file, a
  project's CLAUDE.md no longer needs the sovereignty banner, the method bullets, the memory section or
  the proactivity list: they restate the global block or what the runtime already reports. *Measure:*
  count the lines of those four blocks. *Do:* propose removing them in ONE write; the description, the
  entry points, the gotchas, the tools table and the user's rules stay.
- **THE HORIZON.** The open-work block is injected at every session start with a budget of 4.000
  characters, and whatever passes it does not arrive. The horizon is a section of the same register
  holding what is not for this phase, each item with the CONDITION that brings it in. *Measure:* the
  characters between the `hi-claude:en-curso` markers, minus HTML comments, against 4.000; then look
  for a `## Horizonte` / `## Horizon` heading. *Do:* move there what has not started.
- **THE REGISTER IS RECOGNIZED WHERE IT LIVES.** The start and the turn-close hook accept the same set:
  `docs/ROADMAP.md`, the repo root, and one level down; vendor and build directories are excluded.
  *Measure:* where is the file, and do the markers exist with real content between them? *Do:* move
  the register to one of the three places, or add the markers around the work that is actually open.
- **RULES OF THE EVIDENCE.** A rule glued to the figure and the date of the case that produced it
  expires inside a text that does not. *Measure:* grep CLAUDE.md and the memory directory for dates and
  run figures. *Do:* propose moving each to the evidence document under `docs/`, leaving the rule and
  the path.

## Edge cases

- Project with no CLAUDE.md → skip that auditor; suggest `/hi-claude:setup` instead.
- Project with no `docs/ROADMAP.md` → skip that auditor; offer to create the register.
- Project with no inventory document → skip that auditor; offer to build it
  (`/hi-claude:setup` phase 5), which is what makes the project's tooling usable at all.
- Project with no `docs/` → skip the currency auditor; there is nothing to have expired.
- **A deletion is proposed, never executed on the auditor's word.** Show what is inside the file, what
  was checked by EFFECT to conclude it expired, and what invariant gets rescued before it goes. Nothing
  the CURRENT working block produced is proposed for pruning: its closing evidence has not landed.
- Every criterion met and no findings → say so plainly with the numbers; do not invent work.
- What an auditor brings is a HYPOTHESIS. Verify each finding first-hand against the file before
  proposing it to the user — a report is evidence to check, never a decision already made.
- Do NOT trigger this skill during normal development tasks; only on explicit audit intent or an
  accepted suggestion.
