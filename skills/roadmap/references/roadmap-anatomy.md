# Anatomy of §0 — the execution map

> `§0` is read BEFORE taking an item. It is what turns a list of pendings into a plan.

## Closing routes

Every item is one of five. A work session closes the `[C]`; the rest it leaves READY, which is not the
same as closed.

| Route | What it needs beyond the work | What a session can do |
|---|---|---|
| `[C]` work | nothing | close it: change + check + commit |
| `[V]` verify | the real world — a deploy, a publication, a third party, a real event | leave the change standing and the EXACT query that closes it |
| `[O]` operation | a dead window, a drained queue, coordination, an access you do not have | leave the runnable checklist — do not fire it |
| `[D]` decision | the user's GO | bring the NUMBER that decides, not the argument |
| `[B]` measurement | a dedicated session | do not touch it: out of scope |

**Unmarked = `[C]`.** Only mark what a session cannot close alone, because that is the information
that saves time. An item marked wrong gets re-marked the moment it is discovered, not ignored.

An item's route can change what "done" means without changing the work: a `[V]` is finished when the
change is up and the closing query is written down, not when it is verified.

## Hubs

A hub is an item that CLOSES or UNBLOCKS others. It goes first, always, even when it is bigger.

How to spot one: while writing an item, you find yourself writing "this depends on…", or the same
prerequisite shows up in three separate items. That prerequisite is the hub. Name it in `§0` with one
line saying what it unblocks — that line is what stops a future session from starting at the wrong end.

## Defect classes

Sixty bullets are rarely sixty jobs. They are usually ten CLASSES of defect, each with one rule that
closes all of its members at once.

**Take the class, not the bullet.** A loose bullet from an open class gets fixed three times, because
the cause is still there. The table lives in `§0` and looks like this:

| # | Class | The rule that closes it | ~Items |
|---|---|---|---|

Write the rule as an INVARIANT ("every read returns an explicit state"), never as a list of fixes. The
detail of each finding stays in its thematic block, which is where it gets verified before touching
anything.

## Same root cause in several places

When the same cause is written in more than one item, say so explicitly in `§0`: it gets fixed once and
the other lines get deleted. Two items describing one bug are a trap for whoever takes the second.

## The clash rule

**When two project rules collide, the more restrictive one wins, and the clash is DECLARED in `§0`.**
Declaring it means the next session does not have to think it through again. A clash left implicit gets
re-litigated every time someone hits it.

## The session-done criterion

Mechanical, runnable, and run BEFORE declaring anything. It lives in `§0` because it changes with the
project, and a rule lives in exactly one file.

- Code → the test suite green, the linter clean, the build exit 0.
- Content → the file published and reachable at its URL.
- Research → every claim with its source cited and reachable.

Plus, per closed item, its `(Done: …)` fulfilled with the evidence in view — not "it should work".

## A register a PIECE can check

A register nobody can verify is one that ages on its own: knowing what is closed means re-reading it
whole and re-measuring by hand, so the session re-discovers, re-measures, and sometimes redoes. The
way out is not a bigger register — it is making the register CHECKABLE, and that is a contract about
how items are written, not a tool the method ships.

Three invariants. None of them names a language, a runner or a test framework, because the register
of a Rust project and of a content project are checked by different pieces and written the same way.

1. **The runnable forms live in the PIECE, never in the item.** The project declares a small closed
   set of shapes its checker knows how to run — a count that must equal N, a path that must exist, a
   command whose exit code decides, a query whose result decides. A criterion only its author
   understands is not verifiable, which is the defect being closed. A new shape is added to the piece.
2. **What it cannot measure comes back as a THIRD state.** Not "open", not "done" — unmeasurable, with
   the reason. Reading it as open makes the register look healthy by omission; reading it as done
   deletes a live pending. A base that was locked and a criterion written for a test that does not
   exist yet are both information, and neither is debt.
3. **The count of criteria the piece cannot read is a CEILING THAT ONLY GOES DOWN.** Demanding the
   shape retroactively leaves the suite red over work that is not the current session's, and an
   inherited red is one everybody learns to ignore — which destroys the guard. Pinning the number
   instead means rewriting one lowers it and a new badly-written one raises it and goes red on the
   spot. The ceiling is MEASURED against the register, never estimated: set by feel it leaves invisible
   slack for exactly the items it exists to catch.

Two things that decide whether this pays, both measurable before committing to it:

- **The denominator is the items that ADMIT a runnable criterion**, not the register. A route that
  waits for the real world, a window, a decision or a dedicated measurement does not close with a
  command, so demanding one produces a rewriting queue nobody can close and a number that says
  nothing. On a register where most items are measurements or verifications, the checkable share is
  small and the contract buys little — that is a reason to measure the split first.
- **Coverage grows by USE, not by a dedicated pass.** Turning the criterion runnable is the first move
  when TAKING an item. Measured on one register carried this way across ~1.400 commits, the share of
  items with a runnable criterion sat at 3%: what the piece delivered was not a verified register but
  an exact count of how much of it could not be verified, plus a number that could only fall. That is
  worth having and it is not the same promise — saying which one is being bought is part of the
  contract.

## Decisions that block

A table of what needs the user's GO before its work can start, each with the place where its context
lives. An item sitting in the register without this flag looks takeable and is not; that is a wasted
session.

| # | Decision | Where |
|---|---|---|
