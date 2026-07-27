---
name: seeding-doubts
description: Use whenever quality stalls, something feels off without a clear cause, the user says it cannot be done, or a big block of work just closed (inverse pre-mortem) — even when they only ask you to look again. Triggers on "algo anda mal y no sé qué", "no se puede", "estamos estancados", "qué se nos está escapando", "revisá todo de nuevo", "we're stuck", "what are we missing", "something's off", "nothing is improving", "take another look". Produces MORE doubts to measure, never conclusions, under the hi-claude method.
---

# Seeding doubts (hi-claude)

There is no "it can't be done" — there is an angle not tried yet. This protocol manufactures the
angle.

## When it runs

- A quality stall: "something is wrong and I don't know what".
- Right after closing a big block, as an inverse pre-mortem: what did we NOT look at?
- Periodically, even when nothing looks wrong — especially then.

## The five steps

1. **Sequential introspection.** Everything that caught your attention and was never chased:
   anomalies seen in passing, hunches, odd repeated numbers, doc↔code contradictions, things that
   "are surely fine". One thought = one doubt with its why. **Forbidden to resolve: only formulate.**

2. **Seed three subagents with DISTINCT TONES.** Each receives the seeds "under the speculation that
   something catches my eye", and its deliverable is MORE DOUBTS, never answers. Tones that work:
   - the **HOSTILE METHODOLOGIST** — method, overfitting, baselines, what the sample cannot support
   - the **PARANOID AUDITOR** — the data pipeline, "what if the cache photographed garbage?"
   - the **END USER** — the product, what is missing, the honesty of the track record

   Distinct tones matter more than more agents: three copies of the same lens find the same thing.
   They are read-only and what they bring is a hypothesis — verify it first-hand before acting.

3. **Distil.** Merge yours with theirs into one list ordered by damage×cost, in blocks: whatever
   touches what is ALREADY published or shipped comes first. Each item is a pending MEASUREMENT,
   never a conclusion. Persist them in `docs/ROADMAP.md`.

4. **Validate the checkable ones IMMEDIATELY.** Anything answerable with a real query, payload, or
   file gets verified on the spot. Confirmed → fix, with the evidence. Refuted → struck out WITH the
   datum that refuted it. A doubt refuted with data is worth as much as a confirmed one, and it stops
   the same doubt from coming back next month.

5. **The rest becomes a measurement.** Nothing is adopted or discarded without its method.

## The golden rules

- The most valuable doubt is the one that INVERTS a previous reading: not "why does X fail?" but "why
  do I BELIEVE the ones that work?".
- A number repeated across different contexts is a TEMPLATE until proven otherwise.
- The honest witness is the large N: what only wins on small samples is overfitting until something
  independent says otherwise.
- Two categories that look alike are suspect in both directions until each is measured on its own.

## Adversarial variant

When the cost of a false positive is high and there is budget for it, a doubt can be closed by having
independent verifiers try to REFUTE it — each with a different lens (correctness, security, does it
reproduce) — keeping only what survives a majority. Use it for that case, not as routine: on ordinary
work the coordination costs more than it returns.
