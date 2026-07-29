---
name: delegation
description: Use BEFORE dispatching any subagent, agent or parallel investigation, and again the moment a subagent's report comes back — under this method a subagent never decides what gets done, and what it returns is a hypothesis nothing may rest on until it is verified first-hand. Triggers on "delegá esto", "mandá un subagente", "investigá esto por separado", "en paralelo", "que lo revise otro", "pedile a un agente", "dispatch a subagent", "spawn an agent", "look into this separately", "in parallel", "have another agent check", and on receiving any agent report, auditor result or research summary that something is about to be built on.
---

# Delegation (hi-claude)

A subagent INVESTIGATES. It never decides what gets done and never touches the project's artefacts —
a PreToolUse policy enforces that, with no escape switch. This skill is the other half: what the
dispatcher asks for, and what it does with what comes back.

## Before dispatching

- **Delegate the LOOKING, never the DECIDING.** "Find every place X happens, with `file:line`" is a
  task. "Decide whether we should migrate" is not — that one is yours, and a subagent asked for it
  returns a confident answer you cannot audit.
- **Never delegate the change.** Not an additive one, not a rename, not a "quick fix". The main agent
  applies every change, so the reasoning behind an edit lives in one place.
- **Name the evidence you want back**: `file:line`, the command that reproduces it, the payload, the
  row. A finding without evidence cannot be verified, which makes it unusable here.
- **Different lenses beat more agents.** Three copies of one question find one thing. Dispatching
  several is worth it when each carries a distinct angle — say the angle in its prompt.
- **Scope it so the answer is checkable.** If you would not know how to disprove the report, the task
  was too broad to be worth delegating.

## When the report comes back

1. **Read it whole**, not a summary of it. What a subagent brings is INPUT to your judgement, never a
   substitute for it.
2. **Verify first-hand before anything rests on it.** Open the file, run the command, read the row. A
   finding is a HYPOTHESIS until you have seen the thing yourself — and this applies just as much to
   a report that agrees with you as to one that does not.
3. **A confident tone is not evidence.** Rank findings by what was shown, never by how it was phrased.
4. **What does not survive verification is struck WITH the datum that struck it.** That is worth as
   much as a confirmed finding, and it stops the same claim from returning next month.
5. **You own the decision, and you say it in your own words.** The report never decides.

## What a subagent may and may not do

| May | May not |
|---|---|
| read, search, inspect | write to code, docs, config, CLAUDE.md or memory |
| run tests, measure, reproduce | dispatch further agents or run workflows |
| write to a temporary destination | decide what gets built, changed or dropped |

Every report closes by citing that limit, verbatim. A report that comes back WITHOUT it is a signal
the role never arrived — read what it says with more scrutiny, not less.

## Neighbours

Three subagents with deliberately different TONES, whose deliverable is more doubts and never
answers, is `hi-claude:seeding-doubts`. That single case is the one this skill does not repeat.
