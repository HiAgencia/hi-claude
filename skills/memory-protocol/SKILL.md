---
name: memory-protocol
description: Governs what enters persistent memory and CLAUDE.md under the hi-claude method. Use whenever the user corrects an approach, confirms a non-obvious decision or a validated approach ("yes, exactly", "sí, exactamente", "perfecto, así"), states a preference or a limit, or says things like "remember", "always", "never do", "I don't like", "for next time", "from now on", "recordá", "siempre", "nunca", "prefiero", "no me gusta", "para la próxima" — even if they don't explicitly ask to save anything. Also use BEFORE writing any file under ~/.claude/projects/*/memory/ or any CLAUDE.md.
---

# Memory Protocol (hi-claude)

Decide whether a piece of knowledge deserves persistence, where it goes, and write it in the canonical format — always with user approval.

## Workflow

1. **Classify against the admission rule.** The candidate must be TIMELESS (true in 5 months), PREFERENTIAL (declared preference), or LIMITING (user-imposed boundary). If none → do NOT persist; say nothing unless asked. If it is documentation or a procedure → offer to put it in `docs/` and reference the path from CLAUDE.md instead.
2. **Check scope.** If the preference applies to ALL of the user's projects (not just this one), propose saving it ONCE at user level (`~/.claude/CLAUDE.md` or `~/.claude/rules/`) instead of duplicating per-project memories.
3. **Choose the destination** using `references/decision-tree.md`. For memory entries, choose the type:
   - `user` — who the user is: role, expertise, how they like to receive output
   - `feedback` — corrections ("don't do X") and validated approaches ("yes, exactly like that")
   - `project` — decisions, priorities, context not in the code
   - `reference` — pointers to external systems (URLs, boards, dashboards)
4. **Draft the entry** in the EXACT format defined in `references/memory-schema.md`. Read that file before writing your first memory of the session.
5. **Propose, then wait.** Show the user (in their language): target filename, type, and the full content. Ask for approval. NEVER write without it — a PreToolUse guard will force confirmation anyway.
6. **Write + index.** On approval: write the file, then add one line to `MEMORY.md`. Keep the index under 200 lines (it truncates silently beyond that); when it passes ~150 lines, propose consolidation first.
7. **Replacements.** If the new knowledge corrects an existing memory, write `Replaces obsolete memory: [[old-name]]` in the body and propose deleting the old file in the same approval.

## Do NOT persist

- Code patterns, conventions, file paths (derivable from the code)
- Git history, bug fixes already applied, ephemeral session state ("today I did X", "pending fix")
- Anything already documented in CLAUDE.md (reference it instead)
- Secrets, tokens, credentials — NEVER, anywhere. Point to env vars or a secret manager.

## Canonical practices (always apply)

- Link related memories with `[[name]]` wikilinks.
- If a rule is contextual, declare it: `EXPLICIT SCOPE: only applies when ...`.
- Date your evidence: "validated N=10, 2026-04-26" beats "this works".
- Memories are short: the rule + why + how to apply. A 90-line memory is a document — move it to `docs/` and keep the path.

## Communication

Always propose and report in the user's language. For non-technical users, avoid jargon: "voy a recordar esto" beats "persisting to memory store".
