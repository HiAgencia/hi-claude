---
name: update
description: Use right after the hi-claude plugin is updated, and whenever the user asks what a new version brings or whether their project has to change because of it. Triggers on "actualicé el plugin", "actualicé hi-claude", "qué trae la nueva versión", "¿tengo que cambiar algo?", "¿me falta aplicar algo?", "¿esto quedó viejo?", "I updated the plugin", "what's new in this version", "do I need to change anything", "is my project using the new stuff", and on /hi-claude:update. Measures THIS project BY EFFECT against what the plugin offers NOW — it is not the full health check, which is hi-claude:audit.
---

# What the plugin offers now, and what this project should do about it

This is not a changelog and it is not an audit. A changelog says what changed and leaves the reading
to you; an audit asks whether everything is healthy. This asks ONE question: **of what the plugin
offers, what is this project not using yet — and does it pay here?**

A project can be perfectly healthy and still be missing every capability listed below. That gap is
invisible to every other check, because nothing else knows what the plugin gained.

## How to run it

1. **Read the panorama below.** It carries what a project may not be using yet, why each one pays, and
   how to measure it.
2. **Measure THIS project by EFFECT** — count the characters, open the directory, run the command.
   Never one text against another, and never assume from the version number: a project may have
   adopted something by hand long before it shipped.
3. **Report only what applies, each with ITS NUMBER for this project.** "Your open-work block is
   11.755 characters and 4.000 arrive" moves someone; "consider using the horizon" does not. What is
   already adopted gets one line saying so, and nothing else.
4. **PROPOSE, never apply.** Say what you would change, in which file, and what it buys. The user
   decides. Anything touching CLAUDE.md or memory follows `hi-claude:memory-protocol`, and anything
   touching the register follows `hi-claude:roadmap`.

If nothing applies, say so in one line and stop. A skill that always finds something to do is one that
gets run once.

---

# The panorama

> **Rewritten at every release, never stacked.** This is not a history: it is the state of what a
> project may still be missing. An item leaves when it stops being adoptable — because `setup`
> generates it and no new project can lack it, or because the capability went away. Git keeps what
> leaves.
>
> **Only what asks something OF THE PROJECT enters.** A change that just works — a permission decided
> better, a demand scaled to the change, a consultation that stopped repeating — asks nothing and does
> not belong here. Without that filter this becomes the changelog it exists to replace.

**Version that carries this panorama: 4.1.0**

## The HORIZON — what is not for now stops taking up the session start

**What it is.** The open-work block is injected at every session start with a budget of 4.000
characters, and whatever passes that budget **does not arrive**. The horizon is a section of the same
register holding what is not for this phase, each item with the CONDITION that brings it in — a thing
that has to become true, never a date. It never rides into the session, so it costs nothing per start.

**Why it pays.** Measured across eight real registers, three overflow: their open-work block arrives
cut, and the session cannot tell. One of them loses 66% of its own open work on every single start —
not once, every time. The cause is almost never big work: it is work that has not started sitting
where started work belongs.

**How to measure it here.** Count the characters between the `hi-claude:en-curso` markers, minus HTML
comments, against 4.000. Then look for a `## Horizonte` / `## Horizon` heading.

**What to do.** Move to the horizon what has not started, with its condition written. Migrating later
is moving a block inside one file — which is why it lives in the register and not in a second document
that would have to be kept in sync.

## THE REGISTER IS RECOGNIZED WHERE IT LIVES

**What it is.** The session start looks for the register at `docs/ROADMAP.md`, at the repo root, and
one level down — the last one for a workspace that holds repos. The turn-close hook now accepts
exactly that same set, so what the start injects is what the close settles on.

**Why it pays.** Measured over real projects, 194 writes to a register — 7,4% of all of them — settled
nothing, because the register sat somewhere the hooks did not look. There the turn closed its loop
correctly and the hook kept demanding, with nothing anywhere saying why. And a register whose
`hi-claude:en-curso` markers are missing or empty injects nothing at all: *"where did we leave off"*
has no answer while the file holds hundreds of lines of live work.

**How to measure it here.** Where is the file, and do the markers exist with real content between them?

**What to do.** Move the register to one of the three places, or add the markers around the work that
is actually open. Vendor directories are excluded on purpose: `node_modules`, `vendor`, `third_party`,
`.venv`, `site-packages`, `.git`, `dist`, `build`, `target`, `.tox`.

## A REGISTER A PIECE CAN CHECK — optional, and saying so is part of it

**What it is.** Three invariants, none tied to a language: the runnable criterion forms live in a piece
the project writes, never in the item · what that piece cannot measure comes back as a THIRD state,
never as "open" · and the count of criteria it cannot read is a ceiling that only goes DOWN.
`hi-claude:roadmap` and its `roadmap-anatomy.md` carry the contract.

**Why it pays, and what it does NOT buy.** A register nobody can verify ages on its own: knowing what
is closed means re-reading it whole and re-measuring by hand. But measured on a register carried this
way across ~1.400 commits, the share of items with a runnable criterion sat at **3%**. What the piece
delivered was not a verified register — it was an exact count of how much of it could not be verified,
plus a number that can only fall. That is worth having and it is not the same promise, so which one is
being bought gets said out loud before anyone commits to it.

**How to measure it here.** The proportion of items carrying a `(Hecho: …)` / `(Done: …)` that a
command could run. And, first, how many items ADMIT one at all: a route waiting on the real world, a
window, a decision or a dedicated measurement does not close with a command, so counting it as missing
produces a number that says nothing.

**What to do.** Adopt it by USE, not in a dedicated pass: turning the criterion runnable is the first
move when TAKING an item. A pass that rewrites the whole register produces a queue nobody closes.
