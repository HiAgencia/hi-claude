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

## Decisions that block

A table of what needs the user's GO before its work can start, each with the place where its context
lives. An item sitting in the register without this flag looks takeable and is not; that is a wasted
session.

| # | Decision | Where |
|---|---|---|
