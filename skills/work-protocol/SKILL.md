---
name: work-protocol
description: Use BEFORE writing, updating, MOVING, MERGING or DELETING any documentation, README, code comment or commit message — this project BANS specific patterns in written work (dated state, verdicts written as final, docs that turn into a chronicle), decides WHERE each content belongs before it is written, and carries the procedure for merging two documents and for pruning text that stopped being true. Writing without it produces text that has to be redone, creating without it produces the twenty-sixth document, and deleting without it loses the invariant that was worth keeping. Also use whenever a doc or comment might contradict the current code, whenever a document describes work that already shipped, whenever two documents look like they cover the same subject, and when closing a problem. Triggers on "documentá", "dejá documentado", "actualizá la doc", "está desactualizado", "no coincide con el código", "esto ya no sirve", "limpiá la documentación", "ya lo hicimos", "borralo", "creá un documento", "dónde va esto", "fusionalos", "esto ya está en otro lado", "write it down", "update the docs", "document what you changed", "is this doc stale", "this is obsolete", "clean up the docs", "we already did this", "create a doc for this", "where should this go", "merge these", "why is this so hard to debug".
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

- **The rule travels WITHOUT its history.** A `CLAUDE.md`, a memory, a code comment and any document
  that loads on its own carry the rule, the limit and the why. The evidence, its N and the case that
  produced the rule live in the evidence document under `docs/`, and the rule points at its path when
  the magnitude matters. An anecdote with its figure glued to a rule is a number that expires inside a
  text that does not.
- In the EVIDENCE document, a measured result is a DATUM with its N and its method, REOPENABLE — never
  a closed verdict. What was measured and not adopted is recorded with the evidence that closed it, and
  with the condition that would reopen it.
- **A methodology still being MEASURED is traced in the register, not written into the design doc.** A
  number that still moves stays out of the spec; what reproduced is stated with its N, what contradicted
  itself across runs is recorded as CONTRADICTED — not averaged, not the run that looked best. The spec
  gets the result when the measurement closes, in one pass, and that includes corrections to what it
  already says.
- **A theory the user states is written down BEFORE it is worked on**, in the document that governs it
  and that CLAUDE.md names — if the next session has to ask for it, it was written, not kept.
- **A name says what the thing IS or what it is FOR.** Never the adjective of the moment (`new`, `old`,
  `current`, `previous`) — it expires and the name keeps lying without anything failing; `legacy` only
  for what is really being retired. And a piece that will host several is never named after its first
  tenant: name it by its owner or its function. The moment to ask is when CREATING it.
- **A document is edited with the edit tool, never with a script.** Not `sed`, not an interpreter, not
  a splice by line number: a script hits the line and misses the meaning, and the change cannot be
  reviewed until it is done. A change too big for the edit tool is several changes.
- Documentation does NOT accumulate history. Each line is judged by whether it serves a FUTURE
  session. What describes what already happened — an executed plan, a done-mark, the chronicle of what
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

## Where it BELONGS

The BELONGING axis: the Constitution defines the principle, here is how a destination gets decided.

**Before writing, the destination question comes first.** A content can be true, well written and
still useful — satisfying every other axis — and still land in the wrong document, where nothing
dislodges it: pruning does not touch it because it is not rotten.

| What you have in hand | Where it goes |
|---|---|
| what is MISSING | `docs/ROADMAP.md`, and the context it carries dies with its item |
| what EXISTS now | the live picture, corrected in place |
| what a session opens EVERY time | the root of `docs/`, declared one by one in CLAUDE.md |
| everything else | the ONE context document — a new file is the LAST option |

**Creating a document is the last option, not the first.** What comes up goes into an existing one.
A subfolder is only born once one subject already HAS several documents, and then CLAUDE.md declares
the folder as a unit instead of each path.

**The merge order — it does not get reordered:** rescue → verify the content IS in the destination →
only then delete. An overlap reported by an audit is a hypothesis: deleting on the report alone loses
whatever lived only there. And what gets rescued is rarely about the folder it sat in — content lives
where it was DISCOVERED, not where it belongs.

**Moving is not pruning.** Carrying something to its home destroys nothing, so the distance rule does
not hold it back: it can be done in the same turn. Deleting is what waits for closing evidence.

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
   CAREFUL: **"git keeps it" does NOT hold for a file INSIDE the repo that git never tracked.** There
   is no copy, deleting is irreversible, and the decision stops being hygiene and becomes the user's:
   ask. Look at the CONTENT first — a generated mirror whose source is still alive loses nothing, an
   original without a backup is lost whole, and the two look identical in the explorer. Outside any
   repo the rule never applied, so there is nothing to warn about: scratch and fallback material has
   its own convention, and deleting it once the run completed is the last step of the work.
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
- **Write the invariant, not the prohibition.** When the form is unclear, the surrounding code rules:
  same comment density, same names, same idiom.

## How a failure gets READ

- **When the user says something fails, the first move is to OPEN the files that take part, whole, and
  compare them with each other.** Theorising is allowed only IN ADDITION to reading, never instead of
  it: the hypothesis is checked against the open code, not against a command's output or against what
  is remembered of the script. Comparing two outputs and deducing the cause is what this forbids — the
  output is the effect, the cause lives in the lines that were not opened.
- **Before modifying a piece, read it whole, and with it every piece that feeds it or consumes it** —
  what writes the table, what merges it, what dedupes it, what measures it, and their tests. A fix made
  on the piece where the symptom showed is the next pass, not a fix.
- "I read it earlier" does not count across a compaction or after a change: reopen it. And the control
  of a new rule runs through the REAL write path, not through a case written by hand.
- **When the user says "this never happened to me before", compare instead of explaining**: which
  library, plugin or setting is here that was not there. It may end in "something here should change",
  "this behaviour is the right one" or "the difference is real and wanted" — said with evidence, against
  the official docs. Defending the default without having looked at what changed is the failure.

## How it gets VERIFIED

- **"Done" is said ONCE, with the WHOLE control green.** The suites of the touched files are not the
  control. If the whole control is slow it runs in the background and "done" waits for its verdict.
- A project's validations are ONE entry point with flags, named in its `CLAUDE.md`: it derives the
  level from what was touched and states, per level, measured · not measured · could not be measured.
- **A measurement without its control is worth nothing, and it looks exactly like a good one.** Before
  believing a number, check that the control ran: the process that had to compete, the known case that
  had to come back positive, the condition that had to fail.
- **Fixing the instrument is not the work.** A control gets fixed when its error CHANGES A DECISION. If
  the number is off and the decision comes out the same, it goes to the register and the work goes on.
- **On a conflict between a document and a script, the DOCUMENT rules**: a stale script does not fail,
  it returns a well-formed result. Before running anything that costs time, quota or traffic, open the
  document that governs THAT decision — and if CLAUDE.md does not name it, add it there.
- **A tool exists if it ANSWERS in this session**, not because a config file lists it.

## What the agent settles on its own

- What gets written is TRUE and VERIFIED. What is not verified gets VERIFIED; what cannot be, gets
  DELETED. Leaving it in place with a warning is not a third way out: it hands the user a decision they
  cannot check better than whoever found it.
- The user's decisions are scope and taste, anything with outside cost, anything irreversible, and what
  needs their hand. Which of two contradicting figures is right, whether a document went stale, what a
  label is called — those are the agent's. Its own doubt does not turn a technical call into theirs.
- What turns up beside the task and belongs to the same work gets done; a new front does not get opened.
- **An error the user points at is a PATTERN, never one occurrence.** Fix it where they saw it · name
  the pattern in a sentence that does not mention the case · sweep ALL the material for it, by SHAPE —
  enumerate the members of the class and check each, because a search for the wrong word finds only
  some · report what was swept and what turned up, zero included. Writing the rule down is not applying
  it.
- A session dedicated to ONE subject touches that subject only. Closing it includes its own register
  and live picture; it does not include designing the next session.
