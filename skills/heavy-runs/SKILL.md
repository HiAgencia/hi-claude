---
name: heavy-runs
description: |
  Use BEFORE launching anything that loads the machine or runs for a long time - parallel workers, a test suite over a large volume, a harvest, a crawl, an export, a render, a batch of local subagents - and BEFORE re-launching a run that just failed or came back slow. Triggers on "corré la batería", "lanzá la cosecha", "en paralelo", "cuántos workers", "relanzalo", "está lento", "se cayó la sesión", "run the batch", "how many workers", "run it again", "it crashed", "it is slow". Covers the load ceiling, how parallelism is derived instead of guessed, where a run writes, and what gets read before a re-launch.
---

# Heavy runs (hi-claude)

## The ceiling is of the WHOLE machine, and it is also the target

- The limit the user set for CPU and for RAM applies to the SUM of what is running, never to one
  command. Three jobs that each respect it break it together. When the user set none, ask once and
  propose 75%.
- Running far below the ceiling on a free machine is not prudence: it spends the whole window to look
  at a fraction of the material. A run that does not get near the ceiling is STOPPED and what holds it
  back is found first - re-launching without that repeats the same waste.
- Before lowering parallelism, find WHICH resource ran out. It is often not CPU or RAM: ephemeral
  ports, a remote rate limit, a database writer lock. Each limit has its own way out, and fewer workers
  leaves the machine idle with the bottleneck intact.

## Parallelism is DERIVED, never a constant

- From the machine as it is NOW: physical cores (not logical - CPU-bound work gains nothing from SMT)
  times the ceiling, crossed against free RAM times the ceiling divided by what one process takes. The
  SMALLER one rules.
- The number comes from a MEASURED unit cost, not from trying numbers: run regular steps, take the
  MARGINAL delta between consecutive ones (total divided by N drags the fixed cost), and only
  extrapolate once the increments are consistent. The ceiling is then `(limit - base load) / unit cost`.
- It is recomputed WHILE the work runs, for every phase. A limit computed at start and held for the
  whole batch is a fixed number with another name.
- Before adding a heavy job, measure the load over a WINDOW and decide on its PEAK, never on one
  reading - and look at WHAT ELSE is running and whose it is, by command line, before blaming your own.
- A regulator that does not show up in the run's telemetry cannot be claimed to be working. Instrument
  it before saying so.
- The ceiling binds RUNS, not PROBES: when measuring where something tops out, push until it really does.

## Where a run writes is part of its contract

- Before running a script for the first time - a smoke run included - read WHAT it writes and WHERE. A
  small trial that shares its destination with the real campaign overwrites the campaign.
- An ACCUMULATIVE artefact (it gathers runs that cost calls or time) merges or backs up before writing.
  Only a pure DERIVER, which rebuilds everything from its source on every run, overwrites with reason.
  The defect is fixed by CLASS, not file by file.
- Two classes of output, decided by what happens if the file disappears. EPHEMERAL - consumed in the
  same turn - belongs in the system temp dir. FALLBACK - the partial material that lets a long run
  RESUME, and the evidence a register cites - belongs where the system does not clean on its own, in
  the place the user set for it. The fallback is deleted once the run completed and the product is
  out; that cleanup is the last step of the work, not a decision to escalate.

## Before a re-launch

- A heavy script that runs once is launched ONCE. No caches or shortcuts get added to make re-running
  it cheaper: that documents the plan to fail again.
- Every piece of the chain is read WHOLE before the first launch - what writes the table, what merges
  it, what dedupes it, what measures it, what re-requests it, and their tests. The defect lives in the
  neighbouring piece that was not opened.
- Then the inverse pre-mortem (`hi-claude:seeding-doubts`): what was NOT looked at, which number
  repeats across pieces, which reading would INVERT if checked. Each doubt is measured with its control
  BEFORE the launch.
- What needs the user's hand - a privileged command, a restart, an access - is asked for ONCE, at the
  end, with the work complete and verified.
