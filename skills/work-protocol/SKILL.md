---
name: work-protocol
description: Use BEFORE writing, updating or DELETING any documentation, README, code comment or commit message — this project BANS specific patterns in written work (dated state, verdicts written as final, docs that turn into a chronicle) and carries the procedure for pruning text that stopped being true, so writing without it produces text that has to be redone and deleting without it loses the invariant that was worth keeping. Also use whenever a doc or comment might contradict the current code, whenever a document describes work that already shipped, and when closing a problem, to leave the system easier to operate instead of just covering the symptom. Triggers on "documentá", "dejá documentado", "actualizá la doc", "está desactualizado", "no coincide con el código", "esto ya no sirve", "limpiá la documentación", "ya lo hicimos", "borralo", "write it down", "update the docs", "document what you changed", "is this doc stale", "this is obsolete", "clean up the docs", "we already did this", "why is this so hard to debug".
---

# Work protocol (hi-claude)

## How it gets WRITTEN

This skill carries the WRITING axis of the method. The principles themselves are defined in the
Constitution, which every session already carries — here is how a violation is spotted in a draft.

| Spotted in a draft | Rewrite it as |
|---|---|
| a door closed on a future session — any of the shapes the Constitution forbids | the state OBSERVED, plus the condition that would reopen it |
| a cause or an intent asserted without evidence, or a grade where a measurement belongs | the fact and its evidence, no verdict of value |
| something that expires — a date, a state, a moment | the invariant behind it, or it goes unwritten |
| a line already written that stopped being true, or that no future session would open | delete it — see PRUNED below; git keeps what leaves |

- A measured result is a DATUM with its N and its method, REOPENABLE — never a closed verdict. What
  was measured and not adopted is recorded with the evidence that closed it, and with the condition
  that would reopen it.
- Documentation does NOT accumulate history. Each line is judged by whether it serves a FUTURE
  session. What describes what already happened — an executed plan, a "✅ done", the chronicle of what
  changed and why — is DELETED. Its design lives in the work itself and in the commits.
- Pending vs context: a pending register (`ROADMAP.md`) carries only what is missing and how it
  relates to other pendings; when an item closes it is DELETED, not marked done. What is structural
  — architecture, doctrine, contracts — is not a pending: it lives in the context documents.

## How it gets COMMUNICATED

- This is read by an AI: imperative, no narrative, no filler, no war stories. Metric before prose.
- Explain only what changes a decision. Zero tokens on what does not.
- Do not write what is visible by looking at the repo (the file tree, module names, what a docstring
  already says). The tokens go to GOTCHAS: what bites and cannot be deduced.

## How a problem gets CLOSED

Every problem leaves the system **easier to operate** than it was. Not covering the symptom: leaving
the TOOL so the next one — human or AI — solves it in one jump. A log that CLASSIFIES the cause
instead of a generic one, a repair path, a preview flag that shows the output without touching the
real audience, a doc with the diagnosis and its N. It is protocol, not optional.

Any friction to find out, read, or verify the system — digging through runs one by one, guessing
paths, crossing tables by hand, a timeout indistinguishable from an empty result — gets registered,
and its improvement enters the ROADMAP. Register the idea even when it is not implemented now. The
cheaper the system is to read, the more effective every session becomes.

## How it gets PRUNED

The CURRENCY axis of the method: the Constitution defines the principle, here is how it is executed.
Adding is not the only way to close a loop — deleting closes it exactly as well, and a register that
can only grow is one where every claim that expired stays indistinguishable from the ones that did not.

**The measure is never size.** A document is not too long; it is carrying lines that stopped being
true or stopped serving a future session. Report the expired lines, never the total.

The procedure, in order — skipping a step is what turns pruning into losing something:

1. **Verify by EFFECT.** The document never proves its own currency: unticked boxes do not mean the
   work is open, and ticked ones do not mean it is done. Read the code, the shipped version, the
   criterion that runs. What cannot be checked first-hand is not expired — it is UNVERIFIED, and it
   stays until someone can check it.
2. **Rescue the invariant.** Before anything goes, extract what still bites and lives ONLY there — a
   gotcha, a constraint, a refutation that stops the next session from re-proposing a dead end. That
   moves to the document that owns it. What gets deleted is the narration, not the knowledge.
3. **Delete, do not decorate.** It leaves the tree; git keeps it. Not archived, not renamed to
   `-old`, not struck through, not ticked as done. A document marked historical still gets read,
   still costs context, and still has to be ruled on every time someone opens the folder.
4. **Correct the index.** A document that leaves and an index that still declares it is a dead
   reference; a document that stays and no index declares is one no session ever opens.

**The replacement rule.** When vN+1 lands, vN leaves or survives as ONE line saying what it replaced
and why — that line is worth writing only while a session could still reach for the old approach. A
refutation with its evidence is the case that earns it: it stops the next session from re-proposing
what was already measured and discarded.

**The distance rule.** Nothing is pruned in the turn that produced it. What authorises deleting is the
evidence of closure — the runnable criterion that passes, the version shipped, the test green — not the
feeling of having finished. Fresh out of the work, the agent that did it is the worst judge of its own
closure. In the heat: MARK it. Prune when the evidence lands.

**The authority.** The method proposes and recommends; the agent decides; in doubt it asks the user.
Deleting something whose closure is not verified by effect IS doubt. Memory and CLAUDE.md keep needing
explicit approval regardless — a guard enforces it.

## Retroactivity — what you touch, you leave true

### Verify by EFFECT before correcting anything

A text is corrected against what is TRUE NOW, never against another text. When two writings
contradict each other the newer one does not win — the one the measurement contradicts loses.

Drift runs both ways, and both cost the same: written as PENDING what already happened (a flip, a
deploy, a fix), and written as DONE what went stale (a flag that changed, a script that is gone).

What "measure" means is DISCOVERED per project, never assumed:

| To check | Read the effect, not the declaration |
|---|---|
| a test suite | the runner the project actually declares — `package.json` scripts, Makefile, `pyproject`, cargo, go. If none is declared, SAY SO and carry on: never invent a command, never skip the step in silence |
| a gate before shipping | whatever gate the project DECLARES: a script, a hook, a CI job, a risk window. None declared, no gate |
| a live environment | the env inside the container, the endpoint answering, the rows in the table, the workflow actually enabled — not the panel that describes them. No live environment: declare the step skipped, do not simulate it |
| a published number | re-run the script AS COMMITTED. Evidence that no longer reproduces is declared as debt, never left silent |
| the register of open work | whatever the project uses. `docs/ROADMAP.md` under this method; elsewhere a TODO, a backlog, issues. None found: say there is no register |

The correction that costs the most is the one THIS session left stale minutes after writing it. Sweep
what this session touched first, then the files that load every time.

- A doc or comment that contradicts the current code gets corrected as you pass by.
- A line describing something MANUAL, TEMPORARY, or verified ON A DATE is not written as a definitive
  state: it is declared a SNAPSHOT with its evidence and POINTS at the pending item that automates it.
- Never describe as solved, or as normal, something the ROADMAP lists as pending. If such a line went
  stale, the fix is the pending automation — not editing the line to match.
- A comment states the INVARIANT the code sustains, not the audit or the one-off case that produced
  it. A count or a date inside a comment expires on its own.

## How context gets LOADED

- **One rule lives in ONE file.** If it is already in memory, in a skill, or in a runbook, here goes
  the title or nothing. Two copies diverge, and then someone has to decide which one rules before
  working.
- **Progressive disclosure.** The entry document says WHAT exists and WHERE; the detail opens when the
  task asks for it. A document that grows gets split by MOMENT OF USE, not by topic.
- **Write the invariant, not the prohibition.** Contradictory pairs are forbidden ("document whatever
  is needed" + "don't write comments"). When the form is unclear, the surrounding code rules: same
  comment density, same names, same idiom.
- **Rich reference before prose.** A failing test, the function to port, a captured production
  payload, the real HTML — each is worth more than describing it. A spec IS a test.
- **Expressive interface before example.** A flag, an enumerated state, a well-named parameter
  (`shadow=1`, `state: draft→review→live`) teach their own use; an example NARROWS exploration to what
  the example shows.

## Neighbours

When the superpowers plugin is installed: planning a multi-step job → `superpowers:writing-plans`;
declaring something finished → `superpowers:verification-before-completion`. This skill does not
repeat their content. Without them the rules above still stand on their own — evidence before
assertion either way.
