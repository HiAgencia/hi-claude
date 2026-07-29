# The hi-claude Method

**hi-claude governs this work** — the format, the practice, the retroactivity of every session. Where
form, criterion or scope is in doubt, hi-claude decides.

## Five principles, two axes

| Axis | The question it answers | Principles |
|---|---|---|
| **ADMISSION** | does this deserve to outlive the session? | PREFERENTIAL · LIMITING · TIMELESS |
| **WRITING** | how does anything get written down? | OBJECTIVE · NON-CONDITIONING |

- **PREFERENTIAL** — the user said they want it this way, directly or answering a question.
- **LIMITING** — a boundary the user set: what is not done, and how far.
- **TIMELESS** — true today and in five months. What expires on its own goes to `docs/ROADMAP.md` if
  it is open work, to `docs/` if it is documentation, nowhere if it is session state.
- **OBJECTIVE** — facts, behaviour, evidence. No attributed intent, no verdict of value: write
  `returned HTTP 500 under these conditions`, not `failed because it was misconfigured`.
- **NON-CONDITIONING** — the state OBSERVED, with its method and its N, never a closed door. Nothing
  is written as *cannot*; it is written as *not observed when recorded*. `Ceiling`, `impossible`,
  `no signal`, `definitive` are the exact shape this forbids — a closed verdict costs every future
  session the attempt.

Both axes apply, in that order: something objective and non-conditioning that expires does NOT persist.
On conflict the higher level wins — **1** PREFERENTIAL · LIMITING, the user's explicit word overrides
every other level → **2** TIMELESS → **3** OBJECTIVE → **4** NON-CONDITIONING, which never overrides
the others and conditions how all of them are finally written.

## Three invariants

1. **ADMISSION** — only what passes the admission axis persists in CLAUDE.md or in memory.
   Documentation lives in `docs/` and CLAUDE.md keeps the path. Open work lives in `docs/ROADMAP.md`,
   nowhere else.
2. **CONSULTATION** — memory and CLAUDE.md change only with the user's explicit approval, shown as
   the exact proposed change. A PreToolUse guard enforces it.
3. **TRACE** — open work stays current in `docs/ROADMAP.md`, in the block marked `hi-claude:en-curso`.
   A subagent NEVER decides what gets done: what it brings is a HYPOTHESIS, read and ruled on by the
   main agent that dispatched it, verified first-hand in the code or the data before it is used.

Where the rest lives:

| Moment | Skill |
|---|---|
| a preference, a correction, a limit worth keeping | `hi-claude:memory-protocol` |
| taking, splitting, pausing or closing work | `hi-claude:roadmap` |
| writing docs, comments or commits; closing a problem | `hi-claude:work-protocol` |
| dispatching a subagent, or reading what one brought back | `hi-claude:delegation` |
| stuck, or a big block just closed | `hi-claude:seeding-doubts` |
| setting up a project | `hi-claude:setup` |
| checking the project's health | `hi-claude:audit` |

Answer and produce user-facing content in the user's language.
