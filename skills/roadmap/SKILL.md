---
name: roadmap
description: Use at the start of a session to recover what was in progress, when taking, splitting, pausing or closing a piece of work, when the user wants something recorded so it does not get lost, and before a context compaction — even when they only ask you to note it down. Triggers on "what were we doing", "where did we leave off", "what's left", "add this to the backlog", "don't let me forget this", "pending", "roadmap", "qué estábamos haciendo", "en qué quedamos", "qué falta", "anotá esto", "pendientes". Also use BEFORE writing docs/ROADMAP.md or docs/ESTADO.md. Governs the single register of open work under the hi-claude method.
---

# ROADMAP protocol (hi-claude)

`docs/ROADMAP.md` is the single register of what is MISSING. `docs/ESTADO.md` (`STATE.md` in English
projects) is the live picture of what EXISTS. Neither keeps a log.

## The seven rules

1. **An item is DELETED when it reaches 100%** — never marked done. If closing it changed the state of
   the system, that goes in-place into `ESTADO.md`. The design of what was built lives in the work
   itself and in the commits, not in a list of trophies.
2. **The progress line is ONE line, rewritten, never stacked.** `Ya resuelto:` / `Resolved:` carries
   what is already standing, so a session that arrives cold does not redo it. Past two lines, the item
   was several items: split it.
3. **The open-work block holds at most 3 items**, between the `hi-claude:en-curso` markers. That block
   is injected at every session start and is what answers "what were we doing". More than three and it
   stops being an answer.
4. **Closing route**: unmarked = `[C]`, closable by a work session on its own. Mark only what a session
   cannot close alone — `[V]` needs the real world · `[O]` needs a window, access or coordination ·
   `[D]` needs the user's GO · `[B]` needs a dedicated measuring session. Marking only what saves time
   is the whole point of marking.
5. **`(Done: …)` is runnable** when the item admits one — a grep that must return 0, a test that fails
   before and passes after, a command that must exit 0, a URL that must respond. Turning the criterion
   into something runnable is the FIRST move when taking an item. If it cannot be made runnable, that
   is information about the item: it is probably `[V]`, not `[C]`.
6. **Timeless.** No dates, no "today", no "this session". `hi-claude:work-protocol` governs how every
   line is written — same rules as any other document.
7. **HUBS first, classes not bullets.** An item that unblocks others goes first. Twenty defects sharing
   one root cause are ONE job with one rule that closes them all; taking them one by one fixes the same
   thing three times.

## When to touch it

- **Taking work** → move the item into the open-work block and turn its criterion into something
  runnable before writing anything else.
- **Pausing, or before a compaction** → leave what is missing and what is resolved, one line each. After
  a compaction that block is the only thing left of the thread.
- **Closing** → delete the item; update `ESTADO.md` if the system changed. To declare something
  finished, use `superpowers:verification-before-completion` when it is installed: evidence before
  assertion, always.
- **Discovering work** → new item in its thematic block. It only enters the open-work block if it
  starts now.

Native tasks are the mirror of THIS session; the ROADMAP is the truth BETWEEN sessions. The dump goes
tasks → ROADMAP, never the other way, and never automatically.

## Anatomy of §0

The execution map — closing routes, hubs, defect classes, the clash rule, the session-done criterion,
the decisions that block — lives in `references/roadmap-anatomy.md`. Open it when the register grows
past one screen or when an item resists classification.
